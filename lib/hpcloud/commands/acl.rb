require 'hpcloud/commands/acl/grant'
require 'hpcloud/commands/acl/revoke'

module HP
  module Cloud
    class CLI < Thor

      desc 'acl <object/container>', "View the ACL for an object or container."
      long_desc <<-DESC
  View the access control list (ACL) for a container or object. Optionally, you can specify an availability zone.

Examples:
  hpcloud acl :my_container/my_file.txt         # Display the ACL for the object 'my_file.txt':
  hpcloud acl :my_container                     # Display the ACL for the container 'my_container':
  hpcloud acl :my_container -z region-a.geo-1  # Display the ACL for the container 'my_container' for availability zone `region-a.geo-1`:
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def acl(name, *names)
        cli_command(options) {
          names = [name] + names

          ray = []
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.container_head
              ray << resource.to_hash()
            else
              @log.error resource.cstatus
            end
          }
          keys =  [ "public", "readers", "writers", "public_url"]
          if ray.empty?
            @log.display "There are no resources that match the provided arguments"
          else
            Tableizer.new(options, keys, ray).print
          end
        }
      end
    end
  end
end
