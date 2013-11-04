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

require 'hpcloud/lb_algorithms'

module HP
  module Cloud
    class CLI < Thor
      desc 'lb:algorithms', "List the available load balancer algorithms."
      long_desc <<-DESC
  Lists all the available load balancers algorithms.

Examples:
  hpcloud lb:algorithms          # List all algorithms
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "lb:algorithms" do |*arguments|
        columns = [ "name" ]

        cli_command(options) {
          algo = LbAlgorithms.new
          if algo.empty?
            @log.display "There don't seem to be any supported algorithms at the moment"
          else
            ray = algo.get_array(arguments)
            if ray.empty?
              @log.display "There are no algorithms that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end
