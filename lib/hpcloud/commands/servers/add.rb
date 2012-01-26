module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image_id> <flavor_id>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. Server name can be specified with
  or without the preceding colon: 'my_server' or ':my_server'.

Examples:
  hpcloud servers:add :my_server 7 1     # Creates a new server named 'my_server' using supplied options \n

Aliases: none
      DESC
      define_method "servers:add" do |name, image_id, flavor_id|
        # setup connection for compute service
        compute_connection = connection(:compute)
        begin
          # name cannot be assigned yet, only ids available
          server = compute_connection.servers.new(:flavor_id => flavor_id,
                                                  :image_id => image_id,
                                                  :name => name)
          server.save
          display "Created server '#{name}' with id '#{server.id}'."
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end