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

      desc "lb:nodes:update <lb_name_or_id> <node_id> <condition>", "Update a node in a load balancer."
      long_desc <<-DESC
  Update a node in a load balancer with the specified condition.  The id of the node may be used or 'address:port'.

Examples:
  hpcloud lb:nodes:update loady 10.1.1.1:80 DISABLED # Update node '10.1.1.1:80' to 'DISABLED'
  hpcloud lb:nodes:update 220303 1027580 ENABLED # Update node '1027580' to 'ENABLED'
      DESC
      CLI.add_common_options
      define_method "lb:nodes:update" do |lb_name_or_id, name_or_id, condition|
        cli_command(options) {
          lb = Lbs.new.get(lb_name_or_id)
          node = LbNodes.new(lb.id).get(name_or_id, false)
          node.condition = condition
          node.save
          @log.display "Updated node '#{name_or_id}' to '#{condition}'."
        }
      end
    end
  end
end
