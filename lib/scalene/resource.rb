module HP
  module Scalene
    class Resource
    
      REMOTE_TYPES = [:bucket, :bucket_directory, :object]
      LOCAL_TYPES = [:directory, :file]
    
      def self.detect_type(resource)
        if resource[0,1] == ':'
          if resource[-1,1] == '/'
            :bucket_directory
          elsif resource.index('/')
            :object
          else
            :bucket
          end
        elsif resource[-1,1] == '/'
          :directory
        else
          :file
        end
      end
    
      def self.get_mime_type(file)
        # this probably needs some security lovin'
        full_mime = `file --mime -b #{file}`
        full_mime.split(';')[0].chomp
      end
    
    end
  end
end