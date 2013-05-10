module HP
  module Cloud
    class CLI < Thor

      desc "lb:add <name> <algorithm> <protocol> <port>", "Add a load balancer."
      long_desc <<-DESC
  Add a load balancer with the specified name, algorithm, protocol and port.  Optionally, you can specify a TTL (time to live) to adjust load balancer caching of your entry.  The default time to live (TTL) is 3600 (one hour).

Examples:
  hpcloud lb:add mydomain.com. email@example.com        # Create a new load balancer `mydomain.com` with email address `email@example.com`:
  hpcloud lb:add mydomain.com. email@xample.com -t 7200 # Create a new load balancer `mydomain.com` with email address `email@example.com` and time to live 7200:
      DESC
      CLI.add_common_options
      define_method "lb:add" do |name, algorithm, protocol, port|
        cli_command(options) {
          if Lbs.new.get(name).is_valid? == true
            @log.fatal "Load balancer with the name '#{name}' already exists"
          end
          lb = HP::Cloud::LbHelper.new(Connection.instance)
          lb.name = name
          lb.algorithm = algorithm
          lb.protocol = protocol
          lb.port = port
          if lb.save == true
            @log.display "Created lb '#{name}' with id '#{lb.id}'."
          else
            @log.fatal lb.cstatus
          end
        }
      end
    end
  end
end
