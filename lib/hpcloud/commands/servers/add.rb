module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <flavor>", "Add a server."
      long_desc <<-DESC
  Add a new server to your compute account. You must specify an name for the server, a flavor, an image or volume to use and a keypair.  If you are creating a windows server, the flavor must be at least a large and you must specify a security group that has the RDP port open.  Optionally, you can specify a security group, key name, metadata and availability zone.

Examples:
  hpcloud servers:add my_server small -i 7 -k key1          # Create a new small server named 'my_server' with image 7 and key1:
  hpcloud servers:add winserv large -i 100006567 -k winpair -s allowsRDP -p ./winpair.pem # Create a windows server with the specified key, security group, and private key to decrypt the password:
  hpcloud servers:add my_server large -v natty -k key1 -s sg1   # Create a new largte server named 'my_server' using a volume natty, key1 and the sg1 security group:
  hpcloud servers:add my_server small -i 20634 -k key1 -m this=that     # Create a new small server named 'my_server' using the specified image, flavor, key and metadata this=that:
  hpcloud servers:add my_server xlarge -i 7 -k key1 -z az-2.region-a.geo-1  # Create a new server named 'my_server' using a key for  availability zone `az-2.region-a.geo-1`:
      DESC
      method_option :key_name, :required => true,
                    :type => :string, :aliases => '-k',
                    :desc => 'Specify a key name to be used.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Image to use to create the server.'
      method_option :volume,
                    :type => :string, :aliases => '-v',
                    :desc => 'Volume to use to create the server.'
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
      define_method "servers:add" do |name, flavor|
        cli_command(options) {
          srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
          srv.name = name
          srv.set_flavor(flavor)
          srv.set_image(options[:image])
          srv.set_volume(options[:volume])
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
              display "Make sure the security group has RDP port 3389 open"
              display "You may wish to change the password when you log in"
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
