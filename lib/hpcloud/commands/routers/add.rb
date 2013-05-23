module HP
  module Cloud
    class CLI < Thor

      desc "routers:add <name>", "Add a router."
      long_desc <<-DESC
  Add a new router to your network with the specified name and CIDR.  Optionally, you can specify IP version, gateway, DHCP, DNS name servers, or host routes.  The add command will do its best to guess the IP version from the CIDR, but you may override it.  The DNS name servers should be a command seperated list e.g.: 10.1.1.1,10.2.2.2.  The host routes should be a semicolon separated list of destination and nexthop pairs e.g.: 127.0.0.1/32,10.1.1.1;100.1.1.1/32,10.2.2.2

Examples:
  hpcloud routers:add subwoofer netty 127.0.0.0/24        # Create a new router named 'subwoofer':
  hpcloud routers:add subwoofer netty 127.0.0.0/24 -g 127.0.0.1 -d # Create a new router named 'subwoofer' with gateway and DHCP:
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:add" do |name|
        cli_command(options) {
          if Routers.new.get(name).is_valid? == true
            @log.fatal "Router with the name '#{name}' already exists"
          end

          router = HP::Cloud::RouterHelper.new(Connection.instance)
          router.name = name
          router.set_gateway(options[:gateway])
          router.admin_state_up = options[:adminstateup]
          if router.save == true
            @log.display "Created router '#{name}' with id '#{router.id}'."
          else
            @log.fatal router.cstatus
          end
        }
      end
    end
  end
end
