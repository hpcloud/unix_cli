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

      desc "snapshots:add <name> <volume>", "Create a snapshot."
      long_desc <<-DESC
  Create a snapshot with the given name from a volume.  Optionally, you can specify a description.

Examples:
  hpcloud snapshots:add my_snapshot vol10               # Create the new snapshot 'my_snapshot' from the specified volume
  hpcloud snapshots:add my_snapshot vol10 -d 'test vol' # Creates the new snapshot 'my_snapshot' from the specified volume with the description `test vol`
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the snapshot.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      CLI.add_common_options
      define_method "snapshots:add" do |name, volume_name_id|
        cli_command(options) {
          if Snapshots.new.get(name).is_valid? == true
            @log.fatal "Snapshot with the name '#{name}' already exists"
          end
          vol = HP::Cloud::SnapshotHelper.new(Connection.instance)
          vol.name = name
          vol.description = options[:description]
          if vol.set_volume(volume_name_id)
            if vol.save == true
              @log.display "Created snapshot '#{name}' from volume with id '#{vol.id}'."
            else
              @log.fatal vol.cstatus
            end
          else
            @log.fatal "Cannot find volume '#{volume_name_id}'"
          end
        }
      end
    end
  end
end
