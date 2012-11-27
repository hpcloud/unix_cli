require 'hpcloud/acl'

module HP
  module Cloud
    class CLI < Thor

      map 'acl:set' => 'acl:grant'

      desc 'acl:grant <container> <permissions> [user ...]', "Grant the specified permissions."
      long_desc <<-DESC
  Set the Access Control List (ACL) values for the specified container. The supported permissions are r for read, w for write, or rw for read and write. You may specify one or more user for the given permission.  If no user is specified, the permissions are for the public, but public write permissions are not allowed.

Examples:
  hpcloud acl:grant :my_container r    # Allow anyone to read 'my_container'
  hpcloud acl:grant :my_container rw bob@example.com sally@example.com # Allow Bob and Sally to read and write 'my_container'
  hpcloud acl:grant :my_container r billy@example.com # Give Billy read permissions to 'my_container'

Aliases: acl:set
      DESC
      CLI.add_common_options
      define_method 'acl:grant' do |name, permissions, *users|
        cli_command(options) {
          acl = Acl.new(permissions, users)
          if acl.is_valid?
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.grant(acl)
              display "ACL for #{name} updated to #{acl}."
            else
              error resource.error_string, resource.error_code
            end
          else
            error acl.error_string, acl.error_code
          end
        }
      end
    end
  end
end
