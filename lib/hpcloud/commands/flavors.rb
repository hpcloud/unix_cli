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

      map 'flavors:list' => 'flavors'

      desc "flavors [name_or_id ...]", "List available flavors."
      long_desc <<-DESC
  List the flavors in your compute account. You may filter the output by specifying the names or IDs of the flavors you wish to see.  Optionally, you can specify an availability zone.

Examples:
  hpcloud flavors                         # List the flavors
  hpcloud flavors xsmall small            # List the flavors `xsmall` and `small`
  hpcloud flavors -z az-2.region-a.geo-1  # List the flavors for  availability zone `az-2.region-a.geo-1`

Aliases: flavors:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def flavors(*arguments)
        columns = [ "id", "name", "ram", "disk" ]
        cli_command(options) {
          flavors = Flavors.new
          if flavors.empty?
            @log.display "You currently have no flavors."
          else
            ray = flavors.get_array(arguments)
            if ray.empty?
              @log.display "There are no flavors that match the provided arguments"
            else
              Tableizer.new(options, columns, ray).print
            end
          end
        }
      end
    end
  end
end
