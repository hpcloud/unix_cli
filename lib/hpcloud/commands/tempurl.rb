module HP
  module Cloud
    class CLI < Thor
    
      map 'tmpurl' => 'tempurl'
    
      desc 'tempurl <object> ...', 'Create temporary URLs for the given objects.'
      long_desc <<-DESC
  Create temporary URLS for the given objects. Creating a temporary URL is a great way to share an object for a specified period of time without opening up permissions to everyone.  Only people with access to the URL will be able to access the file.  The time period may be specified in seconds (s), hours (h), or days (d).  If you do not specify a time period, the default is two days.  Optionally, an availability zone can be passed in to the command.

Examples: 
  hpcloud tempurl -p7d :my_container/file.txt   # make a temporary URL for 7 days
  hpcloud tempurl -p24h :my_container/file.txt :my_container/other.txt # multiple files or containers for 24 hours
  hpcloud tempurl :my_container/file.txt -z region-a.geo-1  # Optionally specify an availability zone

Aliases: tmpurl
      DESC
      method_option :time_period,
                    :type => :string, :aliases => '-p',
                    :desc => 'time period to keep the url alive'
      CLI.add_common_options
      def tempurl(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = Resource.create(Connection.instance.storage, name)
            url = resource.tempurl(TimeParser.parse(options[:time_period]))
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
