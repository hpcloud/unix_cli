module HP
  module Scalene
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get <object>', 'fetch an object to your local directory'
      long_desc <<-DESC
  Copy an object from a bucket to your current directory.

Examples: 
  scalene get :my_bucket/file.txt

Aliases: fetch
      DESC
      def get(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        if :object == type
          copy(resource, File.basename(path))
        elsif :bucket == type
          error "You can get files, but not buckets."
        else
          error "The object path '#{resource}' wasn't recognized.  Usage: '#{selfname} get :bucket_name/object_name'.", :incorrect_usage
        end
      end

    end
  end
end

