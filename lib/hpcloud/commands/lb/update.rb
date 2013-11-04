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

      desc "lb:update <lb_name_or_id> <name_or_id> <algorithm>", "Update a node in a load balancer."
      long_desc <<-DESC
  Update a load balancer with the specified algorithm.  The name or id of the load balancer may be used to identify it.

Examples:
  hpcloud lb:update loady ROUND_ROBIN # Update node 'loady' to 'ROUND_ROBIN'
  hpcloud lb:update 220303 LEAST_CONNECTIONS # Update node '220303' to 'LEAST_CONNECTIONS'
      DESC
      CLI.add_common_options
      define_method "lb:update" do |name_or_id, algorithm|
        cli_command(options) {
          lb = Lbs.new.get(name_or_id)
          lb.algorithm = algorithm
          lb.save
          @log.display "Updated load balancer '#{name_or_id}' to '#{algorithm}'."
        }
      end
    end
  end
end
