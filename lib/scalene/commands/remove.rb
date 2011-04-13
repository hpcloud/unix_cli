module HP
  module Scalene
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove <resource>', 'remove an object'
      def remove(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        directory = connection.directories.get(bucket)
        if not directory
          error "You don't have a bucket named '#{bucket}'"
          return
        end

        if type == :object
          file = directory.files.get(path)
          if file
            file.destroy
            display "Removed object '#{resource}'."
          else
            error "You don't have a object named '#{path}'."
          end

        elsif type == :bucket
          confirm = ask_with_default "Are you sure you want to remove '#{resource}'", 'n'
          if confirm[0].downcase == 'y'
            send('buckets:remove', bucket)
          end

        else
            error "Could not find resource '#{resource}'. Correct syntax is :bucketname/objectname."
        end
      end

    end
  end
end

