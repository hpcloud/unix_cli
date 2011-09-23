require 'hpcloud/commands/acl/set'

module HP
  module Cloud
    class CLI < Thor

      CANNED_ACLS = %w(private public-read)

      desc 'acl <object/container>', "view the ACL for an object or container"
      long_desc <<-DESC
  View the Access Control List (ACL) for a container or object.

Examples:
  hpcloud acl :my_container/my_file.txt  # Get ACL for object 'my_file.txt'
  hpcloud acl :my_container              # Get ACL for container 'my_container'

Aliases: none
      DESC
      def acl(resource)
        acls = "private"
        type = Resource.detect_type(resource)
        container, key = Container.parse_resource(resource)
        begin
          dir = connection.directories.get(container)
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
        rescue Excon::Errors::NotFound, Excon::Errors::Forbidden => e
          display_error_message(e)
        end
      end

    end
  end
end