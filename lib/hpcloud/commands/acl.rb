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
      CLI.add_common_options()
      def acl(resource)
        cli_command(options) {
          acls = "private"
          type = Resource.detect_type(resource)
          container, key = Container.parse_resource(resource)
          dir = connection(:storage, options).directories.get(container)
          if type == :object
            if dir
              file = dir.files.get(key)
              if file
                acls = file.directory.public? ? "public-read" : "private"
                display acls
              else
                error "No object exists at '#{container}/#{key}'.", :not_found
              end
            else
              error "No object exists at '#{container}/#{key}'.", :not_found
            end
          elsif type == :container
            if dir
              acls = dir.public? ? "public-read" : "private"
              display acls
            else
              error "No container named '#{container}' exists.", :not_found
            end
          else
            error "ACL viewing is only supported for containers and objects. See `help acl`.", :not_supported
          end
        }
      end
    end
  end
end
