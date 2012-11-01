require 'hpcloud/commands/acl/grant'

module HP
  module Cloud
    class CLI < Thor

      CANNED_ACLS = %w(private public-read)

      desc 'acl <object/container>', "View the ACL for an object or container."
      long_desc <<-DESC
  View the access control list (ACL) for a container or object. Optionally, you can specify an availability zone.

Examples:
  hpcloud acl :my_container/my_file.txt         # Display the ACL for the object 'my_file.txt':
  hpcloud acl :my_container                     # Display the ACL for the container 'my_container':
  hpcloud acl :my_container -z region-a.geo-1  # Display the ACL for the container 'my_container' for availability zone `region-a.geo-1`:
      DESC
      CLI.add_common_options
      def acl(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = Resource.create(Connection.instance.storage, name)
            if resource.read_header
              display resource.acl
            else
              error_message resource.error_string, resource.error_code
            end
          }
        }
      end
    end
  end
end
