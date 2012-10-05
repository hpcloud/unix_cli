module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image> <flavor> -k <keypair>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. You must specify an name for the server, an image to use to create the server, a flavor, and a keypair.  If you are creating a windows image, the flavor must be at least a large image and you must specify a security group that has the RDP port open.  Optionally, you can pass in security group, key name, metadata and availability zone.

Examples:
  hpcloud servers:add my_server 7 small -k key1          # Creates a new server named 'my_server' using an image, flavor and a key
  hpcloud servers:add my_server 8 large -k key1 -s sg1 -p ~/.ssh/id_rsa  # Creates a windows server with the specified key, security group, and private key to decrypt the password
  hpcloud servers:add my_server 7 large -k key1 -s sg1   # Creates a new server named 'my_server' using an image, flavor, key and security group
  hpcloud servers:add my_server 7 small -k key1 -m this=that     # Creates a new server named 'my_server' using an image, flavor, key and metadata this=that
  hpcloud servers:add my_server 7 xlarge -k key1 -z az-2.region-a.geo-1  # Optionally specify an availability zone
  hpcloud servers:add winserv 55 xsmall -k key1 -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :key_name, :required => true,
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
      define_method "servers:add" do |name, image_id, flavor|
        cli_command(options) {
          srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
          srv.name = name
          srv.set_flavor(flavor)
          srv.set_image(image_id)
          srv.set_keypair(options[:key_name])
          srv.set_security_groups(options[:security_group])
          srv.set_private_key(options[:private_key_file])
          srv.meta.set_metadata(options[:metadata])
          if srv.save == true
            display "Created server '#{name}' with id '#{srv.id}'."
            if srv.is_windows?
              display "Retrieving password, this may take several minutes..."
              srv.fog.wait_for { ready? }
              display "Windows password: " + srv.windows_password
              if srv.is_valid?
                error srv.error_string, srv.error_code
              end
            end
          else
            error(srv.error_string, srv.error_code)
          end
        }
      end
    end
  end
end
