module HP
  module Scalene
    class Bucket
    
      # parse a bucket resource into bucket name and object key
      def self.parse_resource(resource)
        bucket, *rest = resource.split('/')
        #raise "No bucket resource in '#{resource}'." if bucket[0] != ':'
        bucket = bucket[1..-1] if bucket[0] == ':'
        path = rest.empty? ? nil : rest.join('/')
        path << '/' if resource[-1] == '/'
        return bucket, path
      end
    
      # provide an absolute path for use as a storage key
      def self.storage_destination_path(destination_path, current_location)
        if destination_path.to_s.empty?
          File.basename(current_location)
        elsif destination_path[-1] == '/'
          destination_path + File.basename(current_location)
        else
          destination_path
        end
      end
    
      def self.bucket_name_for_service(bucket_string)
        if bucket_string[0] == ':'
          bucket_string[1..-1]
        else
          bucket_string
        end
      end
    
      def self.bucket_name_for_display(bucket_string)
      end
    
    end
  end
end