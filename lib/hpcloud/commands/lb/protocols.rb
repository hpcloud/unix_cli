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

require 'hpcloud/lb_protocols'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:protocols', "List the available load balancer protocols."
      long_desc <<-DESC
  Lists all the available load balancers protocols.

Examples:
  hpcloud lb:protocols          # List all protocols
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:protocols" do |*arguments|
        columns = [ "name", "port" ]

        cli_command(options) {
          filter = LbProtocols.new
          if filter.empty?
            @log.display "There don't seem to be any supported protocols at the moment"
          else
            ray = filter.get_array(arguments)
            if ray.empty?
              @log.display "There are no protocols that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end
