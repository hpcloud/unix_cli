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

      map %w(keypairs:rm keypairs:delete keypairs:del) => 'keypairs:remove'

      desc "keypairs:remove name [name ...]", "Remove a key pair (by name)."
      long_desc <<-DESC
  Remove an existing key pair by name. You may specify more than one key pair to remove on a single command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs:remove mykey             # Remove the key pair 'mykey'
  hpcloud keypairs:remove mykey myotherkey  # Remove the key pairs 'mykey' and 'myotherkey'
  hpcloud keypairs:remove mykey -z az-2.region-a.geo-1  # Remove the key pair `mykey` for availability zone `az-2.region-a.geo-1

Aliases: keypairs:rm, keypairs:delete, keypairs:del
      DESC
      CLI.add_common_options
      define_method "keypairs:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          keypairs = Keypairs.new.get(names, false)
          keypairs.each { |keypair|
            sub_command("removing keypair") {
              if keypair.is_valid?
                keypair.destroy
                @log.display "Removed key pair '#{keypair.name}'."
              else
                @log.error keypair.cstatus
              end
            }
          }
        }
      end
    end
  end
end
