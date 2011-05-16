module HP
  module Scalene
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove <object/bucket>', 'remove an object or bucket'
      long_desc <<-DESC
  Remove an object. If the specified target is a bucket, behavior is
  identical to calling `buckets:remove`.
        
Examples:
  scalene remove :my_bucket/my_file.txt   # Delete object 'my_file.txt'
  scalene remove :my_bucket               # Delete bucket 'my_bucket'
        
Aliases: rm, delete, destroy, del
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f',
                    :desc => 'Do not confirm removal, remove non-empty buckets.'

      def remove(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        begin
          directory = connection.directories.get(bucket)
        rescue Excon::Errors::Forbidden => error
          error "Access Denied.", :permission_denied
        end
        if not directory
          error "You don't have a bucket named '#{bucket}'", :not_found
        end

        if type == :object
          begin
            file = directory.files.get(path)
          rescue Excon::Errors::Forbidden => error
            display_error_message(error)
          end
          if file
            file.destroy
            display "Removed object '#{resource}'."
          else
            error "You don't have a object named '#{path}'.", :not_found
          end

        elsif type == :bucket
          if options.force? or yes?("Are you sure you want to remove the bucket '#{resource}'?")
            send('buckets:remove', bucket)
          end

        else
          error "Could not find resource '#{resource}'. Correct syntax is :bucketname/objectname.",
                :incorrect_usage
        end
      end

    end
  end
end

