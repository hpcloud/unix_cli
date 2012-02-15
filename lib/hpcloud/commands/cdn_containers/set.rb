module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:set <name> <attribute> <value>", "set attributes on a CDN container."
      long_desc <<-DESC
  Set attribute for an existing CDN container by specifying its value. The allowed attributes that can
be set are 'X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention'.

Examples:
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900              # sets the attribute 'X-Ttl' to 900
  hpcloud cdn:containers:set :my_cdn_container "X-Cdn-Uri" "http://my.home.com/cdn"     # sets the attribute 'X-Cdn-Uri' to http://my.home.com/cdn
  hpcloud cdn:containers:set :my_cdn_container "X-Cdn-Enabled" True     # sets the attribute 'X-Cdn-Enabled' to True
  hpcloud cdn:containers:set :my_cdn_container "X-Log-Retention" False   # sets the attribute 'X-Log-Retention' to False

Aliases: none
      DESC
      define_method "cdn:containers:set" do |name, attribute, value|
        # check to see cdn container exists
        begin connection(:cdn).head_container(name)
          begin
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && value && allowed_attributes.include?(attribute)
              options = {"#{attribute}" => "#{value}"}
              connection(:cdn).post_container(name, options)
              display "The attribute '#{attribute}' with value '#{value}' was set on CDN container '#{name}'."
            else
              error "The attribute '#{attribute}' cannot be set. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
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