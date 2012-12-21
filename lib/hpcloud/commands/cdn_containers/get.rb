module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:get <name> <attribute>", "Get the value of an attribute of a CDN container."
      long_desc <<-DESC
  Get the value of an attribute for an existing CDN container. The allowed attributes whose value can be retrieved are:
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl"                    # Get the value of the attribute 'X-Ttl':
  hpcloud cdn:containers:get :my_cdn_container "X-Cdn-Uri"                # Get the value of the attribute 'X-Cdn-Uri':
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl" -z region-a.geo-1  # Get the value of the attribute `X-Ttl` for availability zone `regioni-a.geo`:
      DESC
      CLI.add_common_options
      define_method "cdn:containers:get" do |name, attribute|
        cli_command(options) {
          res = ContainerResource.new(Connection.instance.cdn, name)
          name = res.container
          # check to see cdn container exists
          begin
            response = Connection.instance.cdn.head_container(name)
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && allowed_attributes.include?(attribute)
              @log.display response.headers["#{attribute}"]
            else
              @log.fatal "The value of the attribute '#{attribute}' cannot be retrieved. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            end
          rescue Fog::CDN::HP::NotFound => error
            @log.fatal "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
