module HP
  module Cloud
    class CLI < Thor

      desc "routers:update <name> <network_id_or_name> <cidr>", "Add a router."
      long_desc <<-DESC
  Add a new router to your network with the specified name and CIDR.  Optionally, you can specify IP version, gateway, DHCP, DNS name servers, or host routes.  The update command will do its best to guess the IP version from the CIDR, but you may override it.  The DNS name servers should be a command seperated list e.g.: 10.1.1.1,10.2.2.2.  The host routes should be a semicolon separated list of destination and nexthop pairs e.g.: 127.0.0.1/32,10.1.1.1;100.1.1.1/32,10.2.2.2

Examples:
  hpcloud routers:update subwoofer -g 10.0.0.1     # Update 'subwoofer' gateway:
  hpcloud routers:update subwoofer -n 100.1.1.1 -d # Update 'subwoofer' with new DNS and DHCP:
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :adminstateup,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:update" do |name|
        cli_command(options) {
          router = Routers.new.get(name)
          if router.is_valid? == false
            @log.fatal router.cstatus
          end
          router.set_gateway(options[:gateway]) unless options[:gateway].nil?
          router.admin_state_up = options[:adminstateup] unless options[:adminstateup].nil?
          if router.save == true
            @log.display "Updated router '#{name}'."
          else
            @log.fatal router.cstatus
          end
        }
      end
    end
  end
end
