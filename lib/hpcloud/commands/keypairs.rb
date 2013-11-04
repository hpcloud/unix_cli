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

require 'hpcloud/commands/keypairs/import'
require 'hpcloud/commands/keypairs/add'
require 'hpcloud/commands/keypairs/private'
require 'hpcloud/commands/keypairs/public_key'
require 'hpcloud/commands/keypairs/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'keypairs:list' => 'keypairs'

      desc "keypairs [name ...]", "List the available keypairs."
      long_desc <<-DESC
  List the key pairs in your compute account. You may filter the output of keys displayed by specifying the key pairs you want displayed on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs                           # List the key pairs
  hpcloud keypairs brat                      # List the key pair 'brat'
  hpcloud keypairs -z az-2.region-a.geo-1    # List the key pairs for availability zone `az-2.region-a.geo-1`

Aliases: keypairs:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def keypairs(*arguments)
        cli_command(options) {
          keypairs = Keypairs.new
          if keypairs.empty?
            @log.display "You currently have no keypairs, use `#{selfname} keypairs:add <name>` to create one."
          else
            ray = keypairs.get_array(arguments)
            if ray.empty?
              @log.display "There are no keypairs that match the provided arguments"
            else
              Tableizer.new(options, KeypairHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end
