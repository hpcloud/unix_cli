module HP
  module Scalene
    class CLI < Thor
    
      map 'loc' => 'location'
    
      desc 'location <object/bucket>', 'display the URI for a given resource'
      long_desc <<-DESC
  Print the URI of the specified object or bucket. 

Examples: 
  scalene location :my_bucket/file.txt
  scalene location :my_bucket

Aliases: loc
      DESC
      def location(resource)
        bucket, key = Bucket.parse_resource(resource)
        
        if bucket and key
          begin
            if connection.head_object(bucket, key)
              config = Config.current_credentials
              display "http://#{config[:api_endpoint]}/#{bucket}/#{key}"
            end
          rescue Excon::Errors::NotFound => error
            error "No object exists at '#{bucket}/#{key}'.", :not_found
          end
        
        elsif bucket
          begin
            if connection.head_bucket(bucket)
              config = Config.current_credentials
              display "http://#{config[:api_endpoint]}/#{bucket}/"
            end
          rescue Excon::Errors::NotFound => error
            error "No bucket named '#{bucket}' exists.", :not_found
          end
        
        else
          error "Invalid format, see `help location`.", :incorrect_usage
        end
      end
    
    end
  end
end