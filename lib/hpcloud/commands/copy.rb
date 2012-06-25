require 'progressbar'

module HP
  module Cloud
    class CLI < Thor
    
      map 'cp' => 'copy'

      desc 'copy <resource> <resource>', "copy files from one resource to another"
      long_desc <<-DESC
  Copy a file between your file system and a container, inside a container, or
  between containers. Optionally, an availability zone can be passed.

Examples:
  hpcloud copy my_file.txt :my_container        # Copy file to container 'my_container'
  hpcloud copy :my_container/file.txt file.txt  # Copy file.txt to local file
  hpcloud copy :logs/today :logs/old/weds       # Copy inside a container
  hpcloud copy :one/file.txt :two/file.txt      # Copy file.txt between containers
  hpcloud copy my_file.txt :my_container -z region-a.geo-1   # Optionally specify an availability zone

Aliases: cp

Note: Copying multiple files at once or recursively copying folder contents will be supported in a future release.
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def copy(from, to)
        begin
          @storage_connection = connection(:storage, options)

          from_file = Resource.create(from)
          to_file   = Resource.create(to)
          if from_file.isFile() and to_file.isRemote()
            put(from_file, to_file)
          elsif from_file.isObject() and to_file.isLocal()
            put(from_file, to_file)
          elsif from_file.isObject() and to_file.isRemote()
            put(from_file, to_file)
          else
            error "Not currently supported.", :not_supported
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Storage::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized => error
          display_error_message(error, :permission_denied)
        end
      end
    
      no_tasks do
      
        def fetch(from, to)
          if ! from.valid_source()
            error from.error_string, from.error_code
          end

          if ! to.set_destination(from)
            error to.error_string, to.error_code
          end

          begin
            head = @storage_connection.head_object(from.container, from.path)
            siz = head.headers["Content-Length"].to_i
            pbar = ProgressBar.new(File.basename(to.destination), siz)
            File.open(to.destination, 'w') do |file|
              get = @storage_connection.get_object(from.container, from.path) { |chunk, remaining, total|
                file.write chunk
                pbar.inc(chunk.length)
              }
            end
            pbar.finish
            display "Copied #{from.fname} => #{to.get_destination}"
          rescue Fog::Storage::HP::NotFound => e
            error "The specified object does not exist.", :not_found
          rescue Errno::EACCES
            error "You don't have permission to write the target file.", :permission_denied
          rescue Errno::ENOENT, Errno::EISDIR
            error "The target directory is invalid.", :permission_denied
          rescue Excon::Errors::Forbidden => e
            display_error_message(e)
          end
        end
      
        def put(from, to)
          if to.copy(from)
            display "Copied #{from.fname} => #{to.get_destination}"
          else
            if to.error_string.nil?
              if from.error_string.nil?
                error 'Unknown error copying', :unknown
              else
                error from.error_string, from.error_code
              end
            else
              error to.error_string, to.error_code
            end
          end
        end
      
        def clone(from, to)
          container, path = Container.parse_resource(from)
          container_to, path_to = Container.parse_resource(to)
          path_to = Container.storage_destination_path(path_to, path)
          begin
            #### @storage_connection.copy_object(container, path, container_to, path_to)
            @storage_connection.put_object(container_to, path_to, nil, {'X-Copy-From' => "/#{container}/#{path}" })
            display "Copied #{from} => :#{container_to}/#{path_to}"
          rescue Fog::Storage::HP::NotFound => e
            if !@storage_connection.directories.get(container)
              error "You don't have a container '#{container}'.", :not_found
            elsif container != container_to && !@storage_connection.directories.get(container_to)
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
