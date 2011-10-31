module HP
  module Cloud
    class CLI < Thor
    
      map 'cp' => 'copy'

      desc 'copy <resource> <resource>', "copy files from one resource to another"
      long_desc <<-DESC
  Copy a file between your file system and a container, inside a container, or
  between containers.

Examples:
  hpcloud copy my_file.txt :my_container       # Copy file to container 'my_container'
  hpcloud copy :my_container/file.txt file.txt # Copy file.txt to local file
  hpcloud copy :logs/today :logs/old/weds   # Copy inside a container
  hpcloud copy :one/file.txt :two/file.txt  # Copy file.txt between containers

Aliases: cp

Note: Copying multiple files at once will be supported in a future release.
      DESC
      def copy(from, to)
        from_type = Resource.detect_type(from)
        to_type   = Resource.detect_type(to)
        if from_type == :file and Resource::REMOTE_TYPES.include?(to_type)
          put(from, to)
        elsif from_type == :object and Resource::LOCAL_TYPES.include?(to_type)
          fetch(from, to)
        elsif from_type == :object and Resource::REMOTE_TYPES.include?(to_type)
          clone(from, to)
        else
          error "Not currently supported.", :not_supported
        end
      end
    
      no_tasks do
      
        def fetch(from, to)
          container, path = Container.parse_resource(from)
          if File.directory?(to)
            to = to.chop if to[-1,1] == '/'
            to = "#{to}/#{File.basename(path)}"
          end
          dir_path = File.dirname(to) #File.expand_path(file_path)
          if !File.directory?(dir_path)
            error "No directory exists at '#{dir_path}'.", :not_found
          end
          # TODO - ensure expansion to file_destination_path
          begin
            directory = connection.directories.get(container)
          rescue Excon::Errors::Forbidden => e
            error "You don't have permission to access the container '#{container}'.", :permission_denied
          end
          if directory
            begin
              get = connection.get_object(container, path)
              File.open(to, 'w') do |file|
                file.write get.body
              end
              display "Copied #{from} => #{to}"
            rescue Fog::Storage::HP::NotFound => e
              error "The specified object does not exist.", :not_found
            rescue Errno::EACCES
              error "You don't have permission to write the target file.", :permission_denied
            rescue Errno::ENOENT, Errno::EISDIR
              error "The target directory is invalid.", :permission_denied
            rescue Excon::Errors::Forbidden => e
              display_error_message(e)
            end
          else
            error "You don't have a container '#{container}'.", :not_found
          end
        end
      
        def put(from, to)
          if !File.exists?(from)
            error "File not found at '#{from}'.", :not_found
          end
          mime_type = Resource.get_mime_type("'#{from}'")
          container, path = Container.parse_resource(to)
          begin
            directory = connection.directories.get(container)
          rescue Excon::Errors::Forbidden => e
            display_error_message(e)
          end
          key = Container.storage_destination_path(path, from)
          if directory
            begin
              directory.files.create(:key => key, :body => File.open(from), 'Content-Type' => mime_type)
              display "Copied #{from} => :#{container}/#{key}"
            rescue Errno::EACCES => e
              error 'The selected file cannot be read.', :permission_denied
            rescue Excon::Errors::Forbidden => e
              error 'Permission denied', :permission_denied
            end
          else
            error "You don't have a container '#{container}'.", :not_found
          end
        end
      
        def clone(from, to)
          container, path = Container.parse_resource(from)
          container_to, path_to = Container.parse_resource(to)
          path_to = Container.storage_destination_path(path_to, path)
          begin
            #### connection.copy_object(container, path, container_to, path_to)
            connection.put_object(container_to, path_to, nil, {'X-Copy-From' => "/#{container}/#{path}" })
            display "Copied #{from} => :#{container_to}/#{path_to}"
          rescue Fog::Storage::HP::NotFound => e
            if !connection.directories.get(container)
              error "You don't have a container '#{container}'.", :not_found
            elsif container != container_to && !connection.directories.get(container_to)
              error "You don't have a container '#{container_to}'.", :not_found
            else
              error "The specified object does not exist.", :not_found
            end
          end
        end
      
      end
    
    end
  end
end