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

      map %w(routers:rm routers:delete routers:del) => 'routers:remove'

      desc "routers:remove name_or_id [name_or_id ...]", "Remove a router (specified by name or ID)."
      long_desc <<-DESC
  Remove router by specifying their names or ID. You may specify more than one router name or ID on a command line.

Examples:
  hpcloud routers:remove blue red   # Delete the router 'blue' and 'red'
  hpcloud routers:remove 39e36520   # Delete the router with ID 39e36520

Aliases: routers:rm, routers:delete, routers:del
      DESC
      CLI.add_common_options
      define_method "routers:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          routers = Routers.new
          name_or_ids.each{ |name|
            sub_command("removing router") {
              router = routers.get(name, false)
              router.destroy
              @log.display "Removed router '#{router.name}'."
            }
          }
        }
      end
    end
  end
end
