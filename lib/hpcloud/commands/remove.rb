module HPCloud
  class CLI < Thor
    
    map %w(rm delete destroy del) => 'remove'
    
    desc 'remove <resource>', 'remove an object'
    def remove(resource)
      bucket, path = Bucket.parse_resource(resource)
      type = Resource.detect_type(resource)

      confirm = ask_with_default "Are you sure you want to remove '#{resource}'", 'n'
      if confirm[0].downcase == 'y'
        begin
          if type == :object
            # This test for existance will raise a NotFound and print an error
            # We do this because the call to delete_object does not error out if resource doens't exist
            connection.head_object(bucket, path)
            connection.delete_object(bucket, path)
            puts "Removed object #{resource}."
          elsif type == :bucket
            connection.head_bucket(bucket)
            send('buckets:remove', bucket)
          else
            error "I don't understand the resource '#{resource}'"
          end
        rescue Excon::Errors::NotFound => e
          if connection.directories.get(bucket)
            error "The specified object does not exist."
            return
          else
            error "You don't have a bucket '#{bucket}'."
            return
          end
        end
      end
    end
  end
end
