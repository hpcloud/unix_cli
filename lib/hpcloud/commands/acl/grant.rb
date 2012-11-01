module HP
  module Cloud
    class CLI < Thor

      map 'alias:set' => 'alias:grant'

      desc 'acl:grant <resource> <permissions> [user,...]', "Grant the specified permissions."
      long_desc <<-DESC
  Set the Access Control List (ACL) values for the specified containers. The supported ACL settings are private or public-read. Optionally, you can select a specific availability zone.

Examples:
  hpcloud acl:grant :my_container public-read    # Set the 'my_container' ACL value to public-read.
  hpcloud acl:grant :my_container private        # Set the 'my_container' ACL value to private.
  hpcloud acl:grant :my_container public-read -z region-a.geo-1  # Set 'my_container' ACL to public-read for an availability zone.

      DESC
      CLI.add_common_options
      define_method 'acl:grant' do |name, permissions, users=nil|
        cli_command(options) {
          acl = Acl.new(permissions, users)
          if acl.is_valid?
            resource = Resource.create_remote(Connection.instance.storage, name)
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
