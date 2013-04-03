module HP
  module Cloud
    class CLI < Thor

      desc "subnets:update <name> <network_id_or_name> <cidr>", "Add a subnet."
      long_desc <<-DESC
  Add a new subnet to your network with the specified name and CIDR.  Optionally, you can specify IP version, gateway, DHCP, DNS name servers, or host routes.  The update command will do its best to guess the IP version from the CIDR, but you may override it.  The DNS name servers should be a command seperated list e.g.: 10.1.1.1,10.2.2.2.  The host routes should be a semicolon separated list of destination and nexthop pairs e.g.: 127.0.0.1/32,10.1.1.1;100.1.1.1/32,10.2.2.2

Examples:
  hpcloud subnets:update subwoofer -g 10.0.0.1     # Update 'subwoofer' gateway:
  hpcloud subnets:update subwoofer -n 100.1.1.1 -d # Update 'subwoofer' with new DNS and DHCP:
      DESC
      method_option :ipversion,
                    :type => :string, :aliases => '-i',
                    :desc => 'IP version.'
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :dhcp,
                    :type => :boolean, :aliases => '-d',
                    :desc => 'Enable DHCP.'
      method_option :dnsnameservers,
                    :type => :string, :aliases => '-n',
                    :desc => 'Comma separated list of DNS name servers.'
      method_option :hostroutes,
                    :type => :string, :aliases => '-h',
                    :desc => 'Semicolon separated list of host routes pairs.'
      CLI.add_common_options
      define_method "subnets:update" do |name|
        cli_command(options) {
          subnet = Subnets.new.get(name)
          if subnet.is_valid? == false
            @log.fatal subnet.cstatus
          end
          subnet.set_ip_version(options[:ipversion]) unless options[:ipversion].nil?
          subnet.set_gateway(options[:gateway]) unless options[:gateway].nil?
          subnet.dhcp = options[:dhcp] unless options[:dhcp].nil?
          subnet.set_dns_nameservers(options[:dnsnameservers]) unless options[:dnsnameservers].nil?
          subnet.set_host_routes(options[:hostroutes]) unless options[:hostroutes].nil?
          if subnet.save == true
            @log.display "Updated subnet '#{name}'."
          else
            @log.fatal subnet.cstatus
          end
        }
      end
    end
  end
end
