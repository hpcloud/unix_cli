module HP
  module Cloud
    class CLI < Thor
    
      map 'tmpurl' => 'tempurl'
    
      desc 'tempurl <object> ...', 'create temporary URLs for given objects'
      long_desc <<-DESC
  Create temporary URLS for the given objects. Optionally, an availability zone can be passed.

Examples: 
  hpcloud tempurl :my_container/file.txt
  hpcloud tempurl :my_container/file.txt :my_container/other.txt # multiple files or containers
  hpcloud tempurl :my_container/file.txt -z region-a.geo-1  # Optionally specify an availability zone

Aliases: tmpurl
      DESC
      CLI.add_common_options
      def tempurl(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = Resource.create(Connection.instance.storage, name)
            url = resource.tempurl
            unless url.nil?
              display url
            else
              error_message resource.error_string, resource.error_code
            end
          }
        }
      end
    end
  end
end
