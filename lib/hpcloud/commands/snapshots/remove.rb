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

      map %w(snapshots:rm snapshots:delete snapshots:del) => 'snapshots:remove'

      desc "snapshots:remove <name_or_id> [name_or_id ...]", "Remove a snapshot or snapshots (specified by name or ID)."
      long_desc <<-DESC
  Remove snapshots by specifying their names or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud snapshots:remove snappy1 snappy2                # Delete the snapshots `snappy1` and `snappy2`
  hpcloud snapshots:remove 53e78869                       # Delete snapshot with the ID 53e78869
  hpcloud snapshots:remove snappy -z az-2.region-a.geo-1  # Delete snapshot `snappy` for availability zone `az-2.region-a.geo-1`

Aliases: snapshots:rm, snapshots:delete, snapshots:del
      DESC
      CLI.add_common_options
      define_method "snapshots:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          snapshots = Snapshots.new.get(name_or_ids, false)
          snapshots.each { |snapshot|
            sub_command("removing snapshot") {
              if snapshot.is_valid?
                snapshot.destroy
                @log.display "Removed snapshot '#{snapshot.name}'."
              else
                @log.error snapshot.cstatus
              end
            }
          }
        }
      end
    end
  end
end
