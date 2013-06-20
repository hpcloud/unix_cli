module HP
  module Cloud
    class CLI < Thor

      desc "containers:get <name> [attribute...]", "Get the value of an attribute of a container."
      long_desc <<-DESC
  Get the value of an attribute for an existing container. The allowed attributes whose value can be retrieved are:
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud containers:get :my_container                            # List all the attributes
  hpcloud containers:get :my_container "X-Cdn-Uri"                # Get the value of the attribute 'X-Cdn-Uri'
  hpcloud containers:get :my_container "X-Ttl" -z region-a.geo-1  # Get the value of the attribute `X-Ttl` for availability zone `regioni-a.geo`
      DESC
      CLI.add_common_options
      define_method "containers:get" do |name, *attributes|
        cli_command(options) {
          response = Connection.instance.storage.head_container(name)
          allowed_attributes = ['X-Container-Bytes-Used','X-Timestamp','X-Container-Object-Count','X-Container-Read', 'X-Container-Meta-Web-Index', 'X-Container-Meta-Web-Error', 'X-Container-Meta-Web-Listings', 'X-Container-Meta-Web-Listings-CSS']
          if attributes.empty?
            attributes = allowed_attributes
          end
          attributes.each{ |attribute|
            if allowed_attributes.include?(attribute) == false && response.headers["#{attribute}"].nil?
              @log.error "The value of the attribute '#{attribute}' cannot be retrieved. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            else
              value = response.headers["#{attribute}"]
              value = "\n" if value.nil?
              @log.display "#{attribute} #{value}"
            end
          }
        }
      end
    end
  end
end
