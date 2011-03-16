module HPCloud
  class CLI < Thor
    
    map 'loc' => 'location'
    
    desc 'location <resource>', 'display the URI for a given resource'
    def location(resource)
      bucket, key = Bucket.parse_resource(resource)
      begin
        exists = connection.head_object(bucket, key)
        if exists
          puts "http://#{HOST}:#{PORT}/#{bucket}/#{key}"
        end
      rescue Excon::Errors::NotFound => error
        puts "No object exists at '#{bucket}/#{key}'."
      end
    end
    
  end
end