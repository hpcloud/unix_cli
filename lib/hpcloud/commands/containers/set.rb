module HP
  module Cloud
    class CLI < Thor

      desc "containers:set <name> <attribute> <value>", "Set attributes on a container."
      long_desc <<-DESC
  Set attributes for an existing container by specifying their values. The allowed attributes that can be set are:
  
  * 'X-Container-Read'
  * 'X-Container-Meta-Web-Index'
  * 'X-Container-Meta-Web-Error'
  * 'X-Container-Meta-Web-Listings'
  * 'X-Container-Meta-Web-Listings-CSS'
  
Examples:
  hpcloud containers:set :my_container "X-Container-Meta-Web-Index" index.htm                    # Set the attribute 'X-Container-Meta-Web-Index' to index.htm
      DESC
      CLI.add_common_options
      define_method "containers:set" do |name, attribute, value|
        cli_command(options) {
          name = name[1..-1] if name.start_with?(":")
          Connection.instance.storage.head_container(name)
          allowed_attributes = ['X-Container-Read', 'X-Container-Meta-Web-Index', 'X-Container-Meta-Web-Error', 'X-Container-Meta-Web-Listings', 'X-Container-Meta-Web-Listings-CSS']
          if allowed_attributes.include?(attribute) == false
            @log.error "The attribute '#{attribute}' may not be set. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
          end
          options = {"#{attribute}" => "#{value}"}
          Connection.instance.storage.post_container(name, options)
          @log.display "The attribute '#{attribute}' with value '#{value}' was set on container '#{name}'."
        }
      end
    end
  end
end
