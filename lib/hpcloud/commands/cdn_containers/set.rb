module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:set <name> <attribute> <value>", "Set attributes on a CDN container."
      long_desc <<-DESC
  Set attribute for an existing CDN container by specifying its value. The allowed attributes that can be set are 'X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention'. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900                    # sets the attribute 'X-Ttl' to 900
  hpcloud cdn:containers:set :my_cdn_container "X-Cdn-Uri" "http://my.home.com/cdn"     # sets the attribute 'X-Cdn-Uri' to http://my.home.com/cdn
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900 -z region-a.geo-1  # Optionally specify an availability zone
      DESC
      CLI.add_common_options
      define_method "cdn:containers:set" do |name, attribute, value|
        cli_command(options) {
          begin
            connection(:cdn, options).head_container(name)
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && value && allowed_attributes.include?(attribute)
              options = {"#{attribute}" => "#{value}"}
              connection(:cdn, options).post_container(name, options)
              display "The attribute '#{attribute}' with value '#{value}' was set on CDN container '#{name}'."
            else
              error "The attribute '#{attribute}' cannot be set. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            end
          rescue Fog::CDN::HP::NotFound => err
            error "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
