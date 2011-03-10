module HPCloud
  class Bucket
    
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