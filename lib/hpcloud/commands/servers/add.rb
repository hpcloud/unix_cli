module HP
  module Cloud
    class CLI < Thor

      desc "servers:add <name> <image_id> <flavor_id> <key_name> <sg_name>", "add a server"
      long_desc <<-DESC
  Add a new server to your compute account. Optionally, a key name or a security group can be specified.
  Server name can be specified with or without the preceding colon: 'my_server' or ':my_server'.

Examples:
  hpcloud servers:add :my_server 7 1                  # Creates a new server named 'my_server' using an image and flavor \n
  hpcloud servers:add :my_server 7 1 -k key1          # Creates a new server named 'my_server' using an image, flavor and a key \n
  hpcloud servers:add :my_server 7 1 -s sg1           # Creates a new server named 'my_server' using an image, flavor and a security group \n
  hpcloud servers:add :my_server 7 1 -k key1 -s sg1   # Creates a new server named 'my_server' using an image, flavor, key and security group \n

Aliases: none
      DESC
      method_option :key_name, :type => :string, :aliases => '-k', :desc => 'Specify a key name to be used.'
      method_option :security_group, :type => :string, :aliases => '-s', :desc => 'Specify a security group to be used.'
      define_method "servers:add" do |name, image_id, flavor_id|
        # check if options are specified
        key_name = options[:key_name]
        sg_name  = options[:security_group]
        # setup connection for compute service
        compute_connection = connection(:compute)
        begin
          server = compute_connection.servers.create(:flavor_id => flavor_id,
                                                     :image_id => image_id,
                                                     :name => name,
                                                     :key_name => key_name,
                                                     :security_groups => ["#{sg_name}"])
          display "Created server '#{name}' with id '#{server.id}'."
        rescue Excon::Errors::BadRequest => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end
    end
  end
end