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

      map %w(lb:rm lb:delete lb:del) => 'lb:remove'

      desc "lb:remove name_or_id [name_or_id ...]", "Remove load balancer (specified by name or ID)."
      long_desc <<-DESC
  Remove load balancers by specifying their names or ID. You may specify more than one load balacner name or ID on a command line.

Examples:
  hpcloud lb:remove thing1 thing2   # Delete the load balancers `thing1` and `thing2`
  hpcloud lb:remove 998             # Delete the load balancer with ID 998

Aliases: lb:rm, lb:delete, lb:del
      DESC
      CLI.add_common_options
      define_method "lb:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          lbs = Lbs.new
          name_or_ids.each{ |name|
            sub_command("removing load balancer") {
              lb = lbs.get(name, false)
              lb.destroy
              @log.display "Removed load balancer '#{lb.name}'."
            }
          }
        }
      end
    end
  end
end
