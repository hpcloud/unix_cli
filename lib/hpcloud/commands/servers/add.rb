module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image_id> <flavor_id> <key_name> <sg_name>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. Optionally, A key name or a security group can be specified.
  Server name can be specified with or without the preceding colon: 'my_server' or ':my_server'.

Examples:
  hpcloud servers:add :my_server 7 1            # Creates a new server named 'my_server' using supplied options \n
  hpcloud servers:add :my_server 7 1 key1       # Creates a new server named 'my_server' using supplied options \n
  hpcloud servers:add :my_server 7 1 key1 sg1   # Creates a new server named 'my_server' using supplied options \n

Aliases: none
      DESC
      define_method "servers:add" do |name, image_id, flavor_id, key_name=nil, sg_name=nil|
        # setup connection for compute service
        compute_connection = connection(:compute)
        begin
          if (key_name and sg_name)
            server = compute_connection.servers.create(:flavor_id => flavor_id,
                                                       :image_id => image_id,
                                                       :name => name,
                                                       :key_name => key_name,
                                                       :security_groups => ["#{sg_name}"])
            display "Created server '#{name}' with id '#{server.id}', key '#{key_name}' and security group '#{sg_name}'."
          elsif (!key_name and !sg_name)
            server = compute_connection.servers.create(:flavor_id => flavor_id,
                                                       :image_id => image_id,
                                                       :name => name)
            display "Created server '#{name}' with id '#{server.id}'."
          else
            error "You need to specify both a key name and a security group.", :incorrect_usage
          end
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end