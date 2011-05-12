module HP
  module Scalene
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/bucket>', 'display the URI for a given resource'
      long_desc <<-DESC
  Print the URI of the specified object or bucket. 

Examples: 
  scalene location :my_bucket/file.txt

Aliases: loc

Note: Bucket support not yet available.
      DESC
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