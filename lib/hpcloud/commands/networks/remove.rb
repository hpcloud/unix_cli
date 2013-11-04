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

      map %w(networks:rm networks:delete networks:del) => 'networks:remove'

      desc "networks:remove name_or_id [name_or_id ...]", "Remove a network (specified by name or ID)."
      long_desc <<-DESC
  Remove network by specifying their names or ID. You may specify more than one network name or ID on a command line.

Examples:
  hpcloud networks:remove arpa darpa   # Delete the network 'arpa' and 'darpa'
  hpcloud networks:remove 0b78d0cd     # Delete the network with ID 998

Aliases: networks:rm, networks:delete, networks:del
      DESC
      CLI.add_common_options
      define_method "networks:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          networks = Networks.new.get(name_or_ids, false)
          networks.each { |network|
            sub_command("removing network") {
              if network.is_valid?
                network.destroy
                @log.display "Removed network '#{network.name}'."
              else
                @log.error network.cstatus
              end
            }
          }
        }
      end
    end
  end
end
