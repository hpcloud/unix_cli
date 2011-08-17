module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image> <flavor> <avlzone> <groups>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. Server name can be specified with
  or without the preceding colon: 'my_server' or ':my_server'.

Examples:
  hpcloud servers:add :my_server ami-00000005                                     # Creates a new server named 'my_server' using supplied options \n
  hpcloud servers:add :my_server ami-00000005 m1.tiny                             # Creates a new server named 'my_server' using supplied options \n
  hpcloud servers:add :my_server ami-00000005 m1.tiny us-east-1a                  # Creates a new server named 'my_server' using supplied options \n
  hpcloud servers:add :my_server ami-00000005 m1.tiny us-east-1a ['default']      # Creates a new server named 'my_server' using supplied options \n

Aliases: none
      DESC
      define_method "servers:add" do |name, image, flavor="m1.tiny", avlzone="us-east-1a", groups=["default"]|
        # setup connection for compute service
        compute_connection = connection(:compute)
        begin
          # name cannot be assigned yet, only ids available
          server = compute_connection.servers.new(:flavor_id => flavor,
                                            :image_id => image,
                                            :availability_zone => avlzone,
                                            :groups => groups)
          server.save
          display "Created server '#{name}'."
        rescue Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        rescue Fog::HP::Storage::NotFound => error
          error 'The server name specified is invalid. Please see API documentation for valid naming guidelines.', :permission_denied
        end
        # display list of servers
        servers = compute_connection.servers
        if !servers.empty?
          servers.table([:id, :availability_zone, :groups, :flavor_id, :image_id, :created_at, :private_ip_address, :public_ip_address, :state])
        end
      end

    end
  end
end