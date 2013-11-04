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

      map %w(config:add config:update) => 'config:set'

      desc 'config:set key=value [key=value ...]', "Set values in the configuration file."
      long_desc <<-DESC
  Set values in the configuration file.  You may specify multiple name value pairs separated by spaces on a single command line.  Valid settings include:

* connect_timeout (in seconds)
* read_timeout (in seconds)
* write_timeout (in seconds)

Examples:
  hpcloud config:set read_timeout=120     # Set the read timeout to 120 seconds
  hpcloud config:set write_timeout=60 read_time=60    # Set the write timeout to 60 seconds and the read timeout to 60 seconds

Aliases: config:add, config:update
      DESC
      define_method "config:set" do |pair, *pairs|
        cli_command(options) {
          config = Config.new(true)
          updated = ""
          pairs = [pair] + pairs
          pairs.each { |nvp|
            sub_command {
              k, v = Config.split(nvp)
              config.set(k, v)
              updated += " " if updated.empty? == false
              updated += nvp
            }
          }
          if updated.empty? == false
            config.write()
            @log.display "Configuration set " + updated
          end
        }
      end
    end
  end
end
