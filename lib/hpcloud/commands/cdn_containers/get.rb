module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:get <name> <attribute>", "get the value of an attribute on a CDN container."
      long_desc <<-DESC
  Get the value of an attribute for an existing CDN container. The allowed attributes whose value can
be retrieved are 'X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention'.

Examples:
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl"             # gets the value of the attribute 'X-Ttl'
  hpcloud cdn:containers:get :my_cdn_container "X-Cdn-Uri"         # gets the value of the attribute 'X-Cdn-Uri'
  hpcloud cdn:containers:get :my_cdn_container "X-Cdn-Enabled"     # gets the value of the attribute 'X-Cdn-Enabled'
  hpcloud cdn:containers:get :my_cdn_container "X-Log-Retention"   # gets the value of the attribute 'X-Log-Retention'

Aliases: none
      DESC
      define_method "cdn:containers:get" do |name, attribute|
        # check to see cdn container exists
        begin response = connection(:cdn).head_container(name)
          begin
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && allowed_attributes.include?(attribute)
              display response.headers["#{attribute}"]
            else
              error "The value of the attribute '#{attribute}' cannot be retrieved. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            end
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