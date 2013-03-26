module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:set <name> <attribute> <value>", "Set attributes on a CDN container."
      long_desc <<-DESC
  Set attributes for an existing CDN container by specifying their values. The allowed attributes that can be set are:
  
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900                    # Set the attribute 'X-Ttl' to 900:
  hpcloud cdn:containers:set :my_cdn_container "X-Cdn-Uri" "http://my.home.com/cdn"     # Set the attribute 'X-Cdn-Uri' to http://my.home.com/cdn :
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900 -z region-a.geo-1  # Set the attribute `X-Ttl` to 900 for availability zoneregion-a.geo-1`:
      DESC
      CLI.add_common_options
      define_method "cdn:containers:set" do |name, attribute, value|
        cli_command(options) {
          begin
            name = name[1..-1] if name.start_with?(":")
            Connection.instance.cdn.head_container(name)
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && value && allowed_attributes.include?(attribute)
              options = {"#{attribute}" => "#{value}"}
              Connection.instance.cdn.post_container(name, options)
              @log.display "The attribute '#{attribute}' with value '#{value}' was set on CDN container '#{name}'."
            else
              @log.fatal "The attribute '#{attribute}' cannot be set. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            end
          rescue Fog::CDN::HP::NotFound => err
            @log.fatal "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
