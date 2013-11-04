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

      desc "subnets:update <name>", "Update a subnet."
      long_desc <<-DESC
  Update a subnet IP version, gateway, DHCP, DNS name servers, or host routes.  The update command will do its best to guess the IP version from the CIDR, but you may override it.  The DNS name servers should be a command seperated list e.g.: 10.1.1.1,10.2.2.2.  The host routes should be a semicolon separated list of destination and nexthop pairs e.g.: 127.0.0.1/32,10.1.1.1;100.1.1.1/32,10.2.2.2

Examples:
  hpcloud subnets:update subwoofer -g 10.0.0.1     # Update 'subwoofer' gateway
  hpcloud subnets:update subwoofer -n 100.1.1.1 -d # Update 'subwoofer' with new DNS and DHCP
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
