module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:loc' => 'cdn:containers:location'

      desc "cdn:containers:location <name>", "get the location of a container on the CDN."
      long_desc <<-DESC
  Get the location of an existing container on the CDN. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:location :my_cdn_container                     # gets the location of the container 'my_cdn_container'
  hpcloud cdn:containers:location :my_cdn_container -z region-a.geo-1   # Optionally specify an availability zone

Aliases: cdn:containers:loc
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "cdn:containers:location" do |name|
        # check to see cdn container exists
        name = Container.container_name_for_service(name)
        begin
          response = connection(:cdn, options).head_container(name)
          display response.headers['X-Cdn-Uri']
        rescue Fog::CDN::HP::NotFound => err
          error "You don't have a container named '#{name}' on the CDN.", :not_found
        rescue Excon::Errors::BadRequest => error
          display_error_message(error, :incorrect_usage)
        rescue Fog::HP::Errors::ServiceError, Fog::CDN::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::Conflict, Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        end

      end

    end
  end
end
