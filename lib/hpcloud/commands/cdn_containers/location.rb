module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:loc' => 'cdn:containers:location'

      desc "cdn:containers:location <name>", "get the location of a container on the CDN."
      long_desc <<-DESC
  Get the location of an existing container on the CDN.

Examples:
  hpcloud cdn:containers:location :my_cdn_container    # gets the location of the container 'my_cdn_container'

Aliases: cdn:containers:loc
      DESC
      define_method "cdn:containers:location" do |name|
        # check to see cdn container exists
        begin response = connection(:cdn).head_container(name)
          begin
            display response.headers['X-Cdn-Uri']
          rescue Excon::Errors::BadRequest => error
            display_error_message(error, :incorrect_usage)
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error, :permission_denied)
          end
        rescue Fog::CDN::HP::NotFound => err
          error "You don't have a container named '#{name}' on the CDN.", :not_found
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end

      end

    end
  end
end