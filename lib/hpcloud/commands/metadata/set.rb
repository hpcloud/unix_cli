module HP
  module Cloud
    class CLI < Thor

      map 'containers:set' => 'metadata:set'

      desc "metadata:set <name> <attribute> <value>", "Set attributes on a object."
      long_desc <<-DESC
  Set metadata values for containers and objects.  Container metadata keys generally begin with 'X-Container-Meta-' and some other special metadata values you can set for containers include:

#{RemoteResource.VALID_CONTAINER_META}

Object metadata keys generally begin with 'X-Object-Meta-' and some other special metadata values you can set for objects include:

#{RemoteResource.VALID_OBJECT_META}
  
Check http://docs.hpcloud.com/api/object-storage/ for up to date changes on the valid keys and values.  Unfortunately, the server may positively acknowledge the setting of invalid keys.  It may be best to query for the value after setting it to verify the set worked.

Examples:
  hpcloud metadata :my_container "X-Container-Meta-Web-Index" index.htm  # Set the attribute 'X-Container-Meta-Web-Index' to index.htm
  hpcloud metadata:set :my_container/objay.txt X-Object-Meta-Key metavalue     # Set the attribute 'X-Object-Meta-Key' to metavalue
  hpcloud metadata:set :my_container/objay.txt Content-Type text/plain         # Set the attribute 'Content-Type' to text/plain
      DESC
      CLI.add_common_options
      define_method "metadata:set" do |name, attribute, value|
        cli_command(options) {
          resource = ResourceFactory.create(Connection.instance.storage, name)
          unless resource.head
            @log.fatal resource.cstatus
          end
          unless resource.valid_metadata_key?(attribute)
            @log.warn "Metadata key appears to be invalid and your request may be ignored"
          end
          resource.set_metadata(attribute, value)
          @log.display "The attribute '#{attribute}' with value '#{value}' was set on object '#{name}'."
        }
      end
    end
  end
end
