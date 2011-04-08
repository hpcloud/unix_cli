module HPCloud
  class CLI < Thor
    
    map 'cp' => 'copy'
    
    desc 'copy <resource> <resource>', "copy files from one resource to another"
    long_desc 'So much more description...'
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
        error "Not currently supported."
      end
    end
    
    no_tasks do
      
      def fetch(from, to)
        dir_path = File.dirname(to) #File.expand_path(file_path)
        if !Dir.exists?(dir_path)
          error "No directory exists at '#{dir_path}'."
          return
        end
        bucket, path = Bucket.parse_resource(from)
        # TODO - ensure expansion to file_destination_path
        directory = connection.directories.get(bucket)
        if directory
          begin
            get = connection.get_object(bucket, path)
            File.open(to, 'w') do |file|
              file.write get.body
            end
            display "Copied #{from} => #{to}"
          rescue Excon::Errors::NotFound => e
            error "The specified object does not exist."
          end
        else
          error "You don't have a bucket '#{bucket}'."
        end
      end
      
      def put(from, to)
        if !File.exists?(from)
          error "File not found at '#{from}'."
          return
        end
        mime_type = Resource.get_mime_type(from)
        bucket, path = Bucket.parse_resource(to)
        directory = connection.directories.get(bucket)
        key = Bucket.storage_destination_path(path, from)
        if directory
          begin
            directory.files.create(:key => key, :body => File.open(from), 'Content-Type' => mime_type)
            display "Copied #{from} => :#{bucket}/#{key}"
          end
        else
          error "You don't have a bucket '#{bucket}'."
        end
      end
      
      def clone(from, to)
        bucket, path = Bucket.parse_resource(from)
        bucket_to, path_to = Bucket.parse_resource(to)
        begin
          connection.copy_object(bucket, path, bucket_to, path_to)
          display "Copied #{from} => :#{bucket_to}/#{path_to}"
        rescue Excon::Errors::NotFound => e
          if !connection.directories.get(bucket)
            error "You don't have a bucket '#{bucket}'."
          elsif bucket != bucket_to && !connection.directories.get(bucket_to)
            error "You don't have a bucket '#{bucket_to}'."
          else
            error "The specified object does not exist."
          end
        end
      end
      
    end
    
  end
end