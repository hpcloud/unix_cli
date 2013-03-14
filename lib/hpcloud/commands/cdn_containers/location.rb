module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:loc' => 'cdn:containers:location'

      desc "cdn:containers:location <name>", "Get the location of a container on the CDN."
      long_desc <<-DESC
  Get the location of an existing container on the CDN. Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:location :my_cdn_container                     # Get the location of the container 'my_cdn_container':
  hpcloud cdn:containers:location :my_cdn_container -z region-a.geo-1   # Get the location of the container `my_cdn_container` for availability zone `region-a.geo-1`:

Aliases: cdn:containers:loc
      DESC
      method_option :ssl, :default => false,
                    :type => :boolean, :aliases => '-s',
                    :desc => 'Print the SSL version of the URL.'
      CLI.add_common_options
      define_method "cdn:containers:location" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.container_head
              if options.ssl
                @log.display resource.cdn_public_ssl_url
              else
                @log.display resource.cdn_public_url
              end
            else
              @log.error resource.cstatus
            end
          }
        }
      end
    end
  end
end
