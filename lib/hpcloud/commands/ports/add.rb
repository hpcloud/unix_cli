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

      desc "ports:add <name> <network_id_or_name>", "Add a port."
      long_desc <<-DESC
  Add a new port to your network with the specified name.  Optionally, you can specify fixed IPs, MAC address, administrative state, device identifier, device owner, and security groups.

Examples:
  hpcloud ports:add porto netty        # Create a new port named 'porto'
  hpcloud ports:add porto 701be39b -d devvy -o ohnur -u # Create a new port named 'porto' associated with 'devvy' and 'ohnur' administratively up
      DESC
      method_option :fixedips,
                    :type => :string, :aliases => '-f',
                    :desc => 'Fixed IPs.'
      method_option :macaddress,
                    :type => :string, :aliases => '-m',
                    :desc => 'MAC address.'
      method_option :adminstate, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      method_option :deviceid,
                    :type => :string, :aliases => '-d',
                    :desc => 'Device ID.'
      method_option :deviceowner,
                    :type => :string, :aliases => '-o',
                    :desc => 'Device owner.'
      method_option :securitygroups,
                    :type => :string, :aliases => '-g',
                    :desc => 'Security groups.'
      CLI.add_common_options
      define_method "ports:add" do |name, network|
        cli_command(options) {
          if Ports.new.get(name).is_valid? == true
            @log.fatal "Port with the name '#{name}' already exists"
          end
          network = HP::Cloud::Networks.new.get(network)
          if network.is_valid? == false
            @log.fatal network.cstatus
          end

          port = HP::Cloud::PortHelper.new(Connection.instance)
          port.name = name
          port.network_id = network.id
          port.set_fixed_ips(options[:fixedips])
          port.set_mac_address(options[:macaddress])
          port.set_admin_state(options[:adminstate])
          port.set_device_id(options[:deviceid])
          port.set_device_owner(options[:deviceowner])
          port.set_security_groups(options[:security_groups])
          if port.save == true
            @log.display "Created port '#{name}' with id '#{port.id}'."
          else
            @log.fatal port.cstatus
          end
        }
      end
    end
  end
end
