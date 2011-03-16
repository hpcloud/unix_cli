module HPCloud
  class Resource
    
    def self.detect_type(resource)
      if resource[0] == ':'
        if resource[-1] == '/'
          :bucket_directory
        elsif resource.index('/')
          :object
        else
          :bucket
        end
      elsif resource[-1] == '/'
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