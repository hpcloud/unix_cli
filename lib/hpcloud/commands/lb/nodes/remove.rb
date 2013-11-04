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

      map %w(lb:nodes:rm lb:nodes:delete lb:nodes:del) => 'lb:nodes:remove'

      desc "lb:nodes:remove lb_name_or_id node_id [node_id ...]", "Remove the specified load balancer nodes."
      long_desc <<-DESC
  Remove load balancer node by specifying the name or id of the load balancer and the id of the nodes.

Examples:
  hpcloud lb:nodes:remove scale 1044952   # Delete the load balancers ndoe `1044952` from `scale`

Aliases: lb:nodes:rm, lb:nodes:delete, lb:nodes:del
      DESC
      CLI.add_common_options
      define_method "lb:nodes:remove" do |lb_name_or_id, name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          lb = Lbs.new.get(lb_name_or_id)
          name_or_ids.each{ |name|
            sub_command("removing load balancer node") {
              node = LbNodes.new(lb.id).get(name, false)
              node.load_balancer_id = lb.id
              node.destroy
              @log.display "Removed node '#{name}' from load balancer '#{lb_name_or_id}'."
            }
          }
        }
      end
    end
  end
end
