module HP
  module Cloud
    class CLI < Thor

      desc 'acl:revoke <container> <permissions> [user ...]', "Revoke the specified permissions."
      long_desc <<-DESC
  Revoke the access control list (ACL) values from the specified container. The supported permissions are `r` (read), `w` (write), or `rw` (read and write). You may specify one or more user fo the given permission.  If you do not specify a user, the permissions are set to public.  Public write permissions are not allowed.

Examples:
  hpcloud acl:revoke :my_container public-read    # Revoke public read from 'my_container'
  hpcloud acl:revoke :my_container rw bob@example.com # Revoke read and write from bob@example.com from 'my_container'
      DESC
      CLI.add_common_options
      define_method 'acl:revoke' do |name, permissions, *users|
        cli_command(options) {
          acl = AclCmd.new(permissions, users)
          if acl.is_valid?
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.revoke(acl)
              @log.display "Revoked #{acl} from #{name}"
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
