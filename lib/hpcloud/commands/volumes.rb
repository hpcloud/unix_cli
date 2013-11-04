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

require 'hpcloud/commands/volumes/add'
require 'hpcloud/commands/volumes/attach'
require 'hpcloud/commands/volumes/detach'
require 'hpcloud/commands/volumes/remove'
require 'hpcloud/commands/volumes/server'
require 'hpcloud/volumes'

module HP
  module Cloud
    class CLI < Thor

      map 'volumes:list' => 'volumes'
    
      desc 'volumes [name_or_id ...]', "List the available block devices."
      long_desc <<-DESC
  Lists all the block volumes that are associated with the account on the server. The list begins with identifier and contains name, size, type, create date, status, description and servers on which it is attached.  Optionally, you can filter the list by specifying name or ID.

Examples:
  hpcloud volumes          # List all volumes
  hpcloud volumes b8e90a48 # List the details for volume `b8e90a48`
  hpcloud volumes testvol  # List the details for volume `testvol`

Aliases: volumes:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def volumes(*arguments)
        cli_command(options) {
          volumes = Volumes.new
          if volumes.empty?
            @log.display "You currently have no block volume devices, use `#{selfname} volumes:add <name>` to create one."
          else
            ray = volumes.get_array(arguments)
            if ray.empty?
              @log.display "There are no volumes that match the provided arguments"
            else
              Tableizer.new(options, VolumeHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end
