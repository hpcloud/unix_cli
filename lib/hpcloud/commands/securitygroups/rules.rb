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

require 'hpcloud/commands/securitygroups/rules/add'
require 'hpcloud/commands/securitygroups/rules/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'securitygroups:rules:list' => 'securitygroups:rules'

      desc "securitygroups:rules <sec_group_name>", "Display the list of rules for a security group."
      long_desc <<-DESC
  List the rules for a security group for your compute account. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:rules mysecgroup  # List the rules for security group `mysecgroup`
  hpcloud securitygroups:rules c14411d7  # List the rules for security group `c14411d7`

Aliases: securitygroups:rules:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "securitygroups:rules" do |sec_group_name|
        cli_command(options) {
          rules = Rules.new(sec_group_name)
          if rules.empty?
            @log.display "You currently have no rules for the security group '#{sec_group_name}'."
          else
            ray = rules.get_array
            Tableizer.new(options, RuleHelper.get_keys(), ray).print
          end
        }
      end
    end
  end
end
