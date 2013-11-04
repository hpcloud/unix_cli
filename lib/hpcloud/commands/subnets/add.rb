# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module HP
  module Cloud
    class CLI < Thor

      desc "subnets:add <name> <network_id_or_name> <cidr>", "Add a subnet."
      long_desc <<-DESC
  Add a new subnet to your network with the specified name and CIDR.  Optionally, you can specify IP version, gateway, DHCP, DNS name servers, or host routes.  The add command will do its best to guess the IP version from the CIDR, but you may override it.  The DNS name servers should be a command seperated list e.g.: 10.1.1.1,10.2.2.2.  The host routes should be a semicolon separated list of destination and nexthop pairs e.g.: 127.0.0.1/32,10.1.1.1;100.1.1.1/32,10.2.2.2

Examples:
  hpcloud subnets:add subwoofer netty 127.0.0.0/24        # Create a new subnet named 'subwoofer'
  hpcloud subnets:add subwoofer netty 127.0.0.0/24 -g 127.0.0.1 -d # Create a new subnet named 'subwoofer' with gateway and DHCP
      DESC
      method_option :ipversion,
                    :type => :string, :aliases => '-i',
                    :desc => 'IP version.'
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :dhcp, :default => true,
                    :type => :boolean, :aliases => '-d',
                    :desc => 'Enable DHCP.'
      method_option :dnsnameservers,
                    :type => :string, :aliases => '-n',
                    :desc => 'Comma separated list of DNS name servers.'
      method_option :hostroutes,
                    :type => :string, :aliases => '-h',
                    :desc => 'Semicolon separated list of host routes pairs.'
      CLI.add_common_options
      define_method "subnets:add" do |name, network, cidr|
        cli_command(options) {
          if Subnets.new.get(name).is_valid? == true
            @log.fatal "Subnet with the name '#{name}' already exists"
          end
          network = HP::Cloud::Networks.new.get(network)
          if network.is_valid? == false
            @log.fatal network.cstatus
          end

          subnet = HP::Cloud::SubnetHelper.new(Connection.instance)
          subnet.name = name
          subnet.network_id = network.id
          subnet.set_cidr(cidr)
          subnet.set_ip_version(options[:ipversion])
          subnet.set_gateway(options[:gateway])
          subnet.dhcp = options[:dhcp]
          subnet.set_dns_nameservers(options[:dnsnameservers])
          subnet.set_host_routes(options[:hostroutes])
          if subnet.save == true
            @log.display "Created subnet '#{name}' with id '#{subnet.id}'."
          else
            @log.fatal subnet.cstatus
          end
        }
      end
    end
  end
end
