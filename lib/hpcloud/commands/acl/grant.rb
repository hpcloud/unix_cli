require 'hpcloud/acl_cmd'

module HP
  module Cloud
    class CLI < Thor

      map 'acl:set' => 'acl:grant'

      desc 'acl:grant <container> <permissions> [user ...]', "Grant the specified permissions."
      long_desc <<-DESC
  Set the access control list (ACL) values for the specified container. The supported permissions are `r` (read), `w` (write), or `rw` (read and write). You may specify one or more user for the given permission.  If you do not specify a user, the permissions are set to public.  Public write permissions are not allowed.

Examples:
  hpcloud acl:grant :my_container r    # Allow anyone to read 'my_container'
  hpcloud acl:grant :my_container rw bob@example.com sally@example.com # Allow Bob and Sally to read and write 'my_container'
  hpcloud acl:grant :my_container r billy@example.com # Give Billy read permissions to 'my_container'

Aliases: acl:set
      DESC
      CLI.add_common_options
      define_method 'acl:grant' do |name, permissions, *users|
        cli_command(options) {
          acl = HP::Cloud::AclCmd.new(permissions, users)
          if acl.is_valid?
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.grant(acl)
              @log.display "ACL for #{name} updated to #{acl}."
            else
              @log.fatal resource.cstatus
            end
          else
            @log.fatal acl.cstatus
          end
        }
      end
    end
  end
end
