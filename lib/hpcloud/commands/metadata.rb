module HP
  module Cloud
    class CLI < Thor

      map 'containers:get' => 'metadata'

      desc "metadata <name> [attribute...]", "Get the metadata value of a container or object."
      long_desc <<-DESC
  Get the various metadata values for an object or container.

Examples:
  hpcloud metadata :my_container              # List all the attributes
  hpcloud metadata :my_container X-Cdn-Uri    # Get the value of the attribute 'X-Cdn-Uri'
  hpcloud metadata :my_container/dir/file.txt # List all the attributes for the object
      DESC
      CLI.add_common_options
      define_method "metadata" do |name, *attributes|
        cli_command(options) {
          resource = ResourceFactory.create(Connection.instance.storage, name)
          unless resource.head
            @log.fatal resource.cstatus
          end
          if attributes.empty?
            hsh = resource.printable_headers
            keyo = hsh.keys.sort
          else
            hsh = resource.headers
            keyo = attributes
          end
          keyo.each{ |k|
            v = hsh[k]
            v = "\n" if v.nil?
            @log.display "#{k} #{v}"
          }
        }
      end
    end
  end
end
