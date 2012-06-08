module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:get <name> <attribute>", "get the value of an attribute on a CDN container."
      long_desc <<-DESC
  Get the value of an attribute for an existing CDN container. The allowed attributes whose value can
  be retrieved are 'X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention'. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl"                    # gets the value of the attribute 'X-Ttl'
  hpcloud cdn:containers:get :my_cdn_container "X-Cdn-Uri"                # gets the value of the attribute 'X-Cdn-Uri'
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl" -z region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      define_method "cdn:containers:get" do |name, attribute|
        name = Container.container_name_for_service(name)
        # check to see cdn container exists
        begin
          response = connection(:cdn, options).head_container(name)
          allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
          if attribute && allowed_attributes.include?(attribute)
            display response.headers["#{attribute}"]
          else
            error "The value of the attribute '#{attribute}' cannot be retrieved. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
          end
        rescue Fog::CDN::HP::NotFound => error
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