module HP
  module Cloud
    class CLI < Thor
    
      map 'tmpurl' => 'tempurl'
    
      desc 'tempurl <object> ...', 'Create temporary URLs for the given objects.'
      long_desc <<-DESC
  Create temporary URLS for the given objects. Creating a temporary URL allows you to share an object for a specified period of time making it available to everyone.  Only users with access to the URL can access the file.  You can specify the time period in seconds (s), hours (h), or days (d).  If you do not specify a time period, the default is two days.  Optionally, you can specify an availability zone.

Examples: 
  hpcloud tempurl -p7d :my_container/file.txt   # Create a temporary URL for the file `file.txt` with a period of 7 days:
  hpcloud tempurl -p24h :my_container/file.txt :my_container/other.txt #  Create temporary URLs for the files `file.txt` and `other.txt` in container `my_container` with a period of 24 hours:
  hpcloud tempurl :my_container/file.txt -z region-a.geo-1  # Create a temporary URL for the file `file.txt` with a period of 7 days for availability zone `region-a.geo-1`:

Aliases: tmpurl
      DESC
      method_option :time_period,
                    :type => :string, :aliases => '-p',
                    :desc => 'time period to keep the url alive'
      method_option :update,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Update an existing tempurl'
      CLI.add_common_options
      def tempurl(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            url = resource.tempurl(TimeParser.parse(options[:time_period]))
            unless url.nil?
              @log.display url
            else
              @log.error resource.cstatus
            end
          }
        }
      end
    end
  end
end
