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
    
      desc "containers:sync name key [location]", "Allow container synchronization."
      long_desc <<-DESC
  Allow container synchronization using the specified key.  If you are creating a destination for synchronization, only the key should be specified.  If you are creating a source for synchronization, specify a key and location.  The same key must be used in the source and destination.  It is possible to have containers as both a source and destination.  List your synchronization information with the "hpcloud list --sync" command.

Examples:
  hpcloud containers:sync :atainer keyo         # Set up the container :atainer to be a destination for synchronization
  hpcloud containers:sync :btainer keyo atainer # Synchronize :btainer to remote container :atainer
  hpcloud containers:sync :atainer keyo https://region-b.geo-1.objects.hpcloudsvc.com:443/v1/96XXXXXX/btainer     # Create a two way synchronization between :atainer and :btainer
      DESC
      CLI.add_common_options
      define_method "containers:sync" do |name, key, *location|
        cli_command(options) {
          if location.empty?
            location = nil
          else
            location = location[0]
          end
          sub_command("syncing container") {
            res = ContainerResource.new(Connection.instance.storage, name)
            if res.sync(key, location)
              if location.nil?
                @log.display "Container #{name} using key '#{key}'"
              else
                @log.display "Container #{name} using key '#{key}' to #{location}"
              end
            else
              @log.error res.cstatus
            end
          }
        }
      end
    end
  end
end
