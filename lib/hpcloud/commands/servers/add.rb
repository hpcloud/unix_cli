module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image_id> <flavor_id>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. Optionally, a key name and a security group can be specified.  Optionally, the you can pass in security group, key name, metadata and availability zone.

Examples:
  hpcloud servers:add my_server 7 1                  # Creates a new server named 'my_server' using an image and flavor \n
  hpcloud servers:add my_server 7 1 -k key1          # Creates a new server named 'my_server' using an image, flavor and a key \n
  hpcloud servers:add my_server 7 1 -s sg1           # Creates a new server named 'my_server' using an image, flavor and a security group \n
  hpcloud servers:add my_server 7 1 -k key1 -s sg1   # Creates a new server named 'my_server' using an image, flavor, key and security group \n
  hpcloud servers:add my_server 7 1 -m this=that     # Creates a new server named 'my_server' using an image, flavor and metadata this=that \n
  hpcloud servers:add my_server 7 1 -z az-2.region-a.geo-1  # Optionally specify an availability zone
  hpcloud servers:add winserv 55 1 -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :key_name,
                    :type => :string, :aliases => '-k',
                    :desc => 'Specify a key name to be used.'
      method_option :security_group,
                    :type => :string, :aliases => '-s',
                    :desc => 'Specify a security group to be used.'
      method_option :private_key_file,
                    :type => :string, :aliases => '-p',
                    :desc => 'Name of the pem file with your private key.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      CLI.add_common_options
      define_method "servers:add" do |name, image_id, flavor_id|
        cli_command(options) {
          srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
          srv.name = name
          srv.set_flavor(flavor_id)
          srv.set_image(image_id)
          srv.set_keypair(options[:key_name])
          srv.set_security_groups(options[:security_group])
          srv.set_private_key(options[:private_key_file])
          srv.meta.set_metadata(options[:metadata])
          if srv.save == true
            display "Created server '#{name}' with id '#{srv.id}'."
            if srv.is_windows?
              display "Windows password: " + srv.fog.windows_password
            end
          else
            error(srv.error_string, srv.error_code)
          end
        }
      end
    end
  end
end
