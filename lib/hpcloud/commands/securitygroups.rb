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

require 'hpcloud/commands/securitygroups/add'
require 'hpcloud/commands/securitygroups/remove'
require 'hpcloud/commands/securitygroups/rules'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:list' => 'securitygroups'

      desc "securitygroups [name_or_id ...]", "List the available security groups."
      long_desc <<-DESC
  List the security groups in your compute account. You may filter the display by specifying names or IDs of security groups on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups                         # List the security groups
  hpcloud securitygroups mysecgrp                # List security group `mysecgrp`
  hpcloud securitygroups -z az-2.region-a.geo-1  # List the security groups for availability zone `az-2.region-a.geo-1`

Aliases: securitygroups:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def securitygroups(*arguments)
        cli_command(options) {
          securitygroups = SecurityGroups.new
          if securitygroups.empty?
            @log.display "You currently have no security groups, , use `#{selfname} securitygroups:add <name>` to create one."
          else
            ray = securitygroups.get_array(arguments)
            if ray.empty?
              @log.display "There are no security groups that match the provided arguments"
            else
              Tableizer.new(options, SecurityGroupHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end
