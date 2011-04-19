module HP
  module Scalene
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <resource>', 'display the URI for a given resource'
      long_desc "The 'location' command prints the URI of the specified object.
                The URL will have the form of 'http://<host>:<port>/<bucket>/<object>.
                \n\nExamples: 'scalene location :my_bucket/my_file.txt'
                \n\nAliases: 'loc'
                \n\nNote: Supported for objects, not for buckets."
      def location(resource)
        bucket, key = Bucket.parse_resource(resource)
        begin
          exists = connection.head_object(bucket, key)
          if exists
            config = Config.current_credentials
            display "http://#{config[:host]}:#{config[:port]}/#{bucket}/#{key}"
          end
        rescue Excon::Errors::NotFound => error
          error "No object exists at '#{bucket}/#{key}'."
        end
      end
    
    end
  end
end