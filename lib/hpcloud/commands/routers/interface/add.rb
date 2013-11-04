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

      desc "routers:interface:add <router> <subnet_or_port>", "Add an interface to a router."
      long_desc <<-DESC
  Add an interface to your router with the specified subnet or port.

Examples:
  hpcloud routers:interface:add trout subnetty # Add an interface to the subnet 'subnetty'
  hpcloud routers:interface:add trout proto    # Add an interface to the port 'porto'
      DESC
      CLI.add_common_options
      define_method "routers:interface:add" do |name, subnet_or_port|
        cli_command(options) {
          router = Routers.new.get(name)
          subnet_id = nil
          port_id = nil
          subby = Subnets.new.get(subnet_or_port)
          if subby.is_valid?
            subnet_id = subby.id
            newinterface = subnet_id
          else
            porty = Ports.new.get(subnet_or_port)
            unless porty.is_valid?
              @log.fatal "Cannot find a subnet or port matching '#{subnet_or_port}'."
            end
            port_id = porty.id
            newinterface = port_id
          end

          Connection.instance.network.add_router_interface(router.id, subnet_id, port_id)
          @log.display "Created router interface '#{name}' to '#{subnet_or_port}'."
        }
      end
    end
  end
end
