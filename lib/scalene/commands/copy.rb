module HP
  module Scalene
    class CLI < Thor
    
      map 'cp' => 'copy'

      desc 'copy <resource> <resource>', "copy files from one resource to another"
      long_desc <<-DESC
  Copy a file between your file system and a bucket, inside a bucket, or 
  between buckets.

Examples:
  scalene copy my_file.txt :my_bucket       # Copy file to bucket 'my_bucket'
  scalene copy :my_bucket/file.txt file.txt # Copy file.txt to local file
  scalene copy :logs/today :logs/old/weds   # Copy inside a bucket
  scalene copy :one/file.txt :two/file.txt  # Copy file.txt between buckets

Aliases: cp

Note: Copying multiple files at once will be supported in a future release.
  Copying between buckets is disabled pending resolution of a KVS bug.
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
          bucket, path = Bucket.parse_resource(from)
          if File.directory?(to)
            to = to.chop if to[-1,1] == '/'
            to = "#{to}/#{File.basename(path)}"
          end
          dir_path = File.dirname(to) #File.expand_path(file_path)
          if !File.directory?(dir_path)
            error "No directory exists at '#{dir_path}'.", :not_found
            return
          end
          # TODO - ensure expansion to file_destination_path
          begin
            directory = connection.directories.get(bucket)
          rescue Excon::Errors::Forbidden => e
            error "You don't have permission to access the bucket '#{bucket}'.", :permission_denied
          end
          if directory
            begin
              get = connection.get_object(bucket, path)
              File.open(to, 'w') do |file|
                file.write get.body
              end
              display "Copied #{from} => #{to}"
            rescue Excon::Errors::NotFound => e
              error "The specified object does not exist.", :not_found
            rescue Excon::Errors::Forbidden => e
              display_error_message(e)
            end
          else
            error "You don't have a bucket '#{bucket}'.", :not_found
          end
        end
      
        def put(from, to)
          if !File.exists?(from)
            error "File not found at '#{from}'.", :not_found
          end
          mime_type = Resource.get_mime_type("'#{from}'")
          bucket, path = Bucket.parse_resource(to)
          begin
            directory = connection.directories.get(bucket)
          rescue Excon::Errors::Forbidden => e
            display_error_message(e)
          end
          key = Bucket.storage_destination_path(path, from)
          key.sub!(" ", "_")
          if directory
            begin
              directory.files.create(:key => key, :body => File.open(from), 'Content-Type' => mime_type)
              display "Copied #{from} => :#{bucket}/#{key}"
            rescue Errno::EACCES => e
              error 'The selected file cannot be read.', :permission_denied
            rescue Excon::Errors::Forbidden => e
              error 'Permission denied', :permission_denied
            end
          else
            error "You don't have a bucket '#{bucket}'.", :not_found
          end
        end
      
        def clone(from, to)
          bucket, path = Bucket.parse_resource(from)
          bucket_to, path_to = Bucket.parse_resource(to)
          path_to = Bucket.storage_destination_path(path_to, path)
          begin
            connection.copy_object(bucket, path, bucket_to, path_to)
            display "Copied #{from} => :#{bucket_to}/#{path_to}"
          rescue Excon::Errors::NotFound => e
            if !connection.directories.get(bucket)
              error "You don't have a bucket '#{bucket}'.", :not_found
            elsif bucket != bucket_to #&& !connection.directories.get(bucket_to)
              #error "You don't have a bucket '#{bucket_to}'."
              error 'Copying between buckets is not yet supported.', :not_supported
            else
              error "The specified object does not exist.", :not_found
            end
          end
        end
      
      end
    
    end
  end
end