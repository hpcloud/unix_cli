module HP
  module Cloud
    class CLI < Thor

      desc "objects:metadata:set <name> <attribute> <value>", "Set attributes on a object."
      long_desc <<-DESC
  Set attributes for an existing object by specifying their values.
  
Examples:
  hpcloud objects:metadata:set :my_container/objay.txt X-Object-Meta-Key metavalue                    # Set the attribute 'X-Object-Meta-Key' to metavalue
  hpcloud objects:metadata:set :my_container/objay.txt Content-Type text/plain                    # Set the attribute 'Content-Type' to text/plain
      DESC
      CLI.add_common_options
      define_method "objects:metadata:set" do |name, attribute, value|
        cli_command(options) {
          unless attribute.start_with?("X-Object-Meta-")
            unless attribute.start_with?("Content-Type")
              @log.warn "Object metadata attributes should begin with 'X-Object-Meta-' your entry may be ignored"
            end
          end
          resource = ResourceFactory.create(Connection.instance.storage, name)
          if resource.head
            hsh = resource.headers.dup
            hsh.delete('Accept-Ranges')
            hsh.delete('Content-Length')
            hsh.delete('Date')
            hsh.delete('Etag')
            hsh.delete('Last-Modified')
            hsh.delete('X-Timestamp')
            hsh.delete('X-Trans-Id')
            hsh["#{attribute}"] = "#{value}"
            Connection.instance.storage.post_object(resource.container, resource.path, hsh)
            @log.display "The attribute '#{attribute}' with value '#{value}' was set on object '#{name}'."
          else
            @log.error resource.cstatus
          end
        }
      end
    end
  end
end
