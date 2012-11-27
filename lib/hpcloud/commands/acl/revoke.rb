module HP
  module Cloud
    class CLI < Thor

      desc 'acl:revoke <container> <permissions> [user ...]', "Revoke the specified permissions."
      long_desc <<-DESC
  Revoke the permissions from the specified containers. The supported access control list (ACL) settings are r, rw, and w. If no user is specified, it is assumed the ACL is public.

Examples:
  hpcloud acl:revoke :my_container public-read    # Revoke public read from 'my_container'
  hpcloud acl:revoke :my_container rw bob@example.com # Revoke read and write from bob@example.com from 'my_container'
      DESC
      CLI.add_common_options
      define_method 'acl:revoke' do |name, permissions, *users|
        cli_command(options) {
          acl = Acl.new(permissions, users)
          if acl.is_valid?
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.revoke(acl)
              display "Revoked #{acl} from #{name}"
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
