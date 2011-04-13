module HP
  module Scalene
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get <resource>', 'fetch an object to local file system'
      long_desc 'Copies the specified object to the current directory on your local file system. The file will retain the name it it saved with online.'
      def get(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        if :object == type
          copy(resource, "./#{path}")
        elsif :bucket == type
          error "You can get files, but not buckets."
        else
          error "The object path '#{resource}' wasn't recognized.  Usage: '#{selfname} get :bucket_name/object_name'.", :incorrect_usage
        end
      end

    end
  end
end

