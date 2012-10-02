require 'hpcloud/commands/acl/set'

module HP
  module Cloud
    class CLI < Thor

      CANNED_ACLS = %w(private public-read)

      desc 'acl <object/container>', "view the ACL for an object or container"
      long_desc <<-DESC
  View the Access Control List (ACL) for a container or object. Optionally, an availability zone can be passed.

Examples:
  hpcloud acl :my_container/my_file.txt         # Get ACL for object 'my_file.txt'
  hpcloud acl :my_container                     # Get ACL for container 'my_container'
  hpcloud acl :my_container -z region-a.geo-1  # Get ACL for container 'my_container' by specifying an availability zone

Aliases: none
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
