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

      desc "lb:nodes:add <lb_name_or_id> <address> <port>", "Add a node to the load balancer."
      long_desc <<-DESC
  Add a node to the load balancer with the specified adddress and port.

Examples:
  hpcloud lb:nodes:add loady 10.1.1.1 80  # Create a new node for load balancer 'loady'
      DESC
      CLI.add_common_options
      define_method "lb:nodes:add" do |load_balancer_name_or_id, address, port|
        cli_command(options) {
          lb = Lbs.new.get(load_balancer_name_or_id)
          node = Fog::HP::LB::Node.new({:service => Connection.instance.lb, :load_balancer_id => lb.id})
          node.address = address
          node.port = port
          node.save
          @log.display "Created node '#{address}:#{port}' with id '#{node.id}'."
        }
      end
    end
  end
end
