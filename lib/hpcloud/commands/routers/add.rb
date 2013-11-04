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

      desc "routers:add <name>", "Add a router."
      long_desc <<-DESC
  Add a new router to your network with the specified name.  If a gateway is not specified, the first network that has router_external set to true is used (typically 'Ext-Net'.

Examples:
  hpcloud routers:add routerone   # Create a new router named 'routerone'
  hpcloud routers:add routertwo -g Ext-Net   # Create a new router named 'routertwo' with the specified network as a gateway
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Network to use as external router.'
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:add" do |name|
        cli_command(options) {
          router = Routers.new.unique(name)
          router.name = name
          netty = Routers.parse_gateway(options[:gateway])
          if netty.nil?
            router.external_gateway_info = {}
          else
            router.external_gateway_info = { 'network_id' => netty.id }
          end
          router.admin_state_up = options[:adminstateup]
          router.save
          unless netty.nil?
            unless netty.subnets.nil?
              unless netty.subnets.empty?
                sub_command("add router interface for subnet") {
                  Connection.instance.network.add_router_interface(router.id, netty.subnets, nil)
                }
              end
            end
          end
          @log.display "Created router '#{name}' with id '#{router.id}'."
        }
      end
    end
  end
end
