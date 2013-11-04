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

      map %w(securitygroups:rules:rm securitygroups:rules:revoke securitygroups:rules:delete securitygroups:rules:del) => 'securitygroups:rules:remove'

      desc "securitygroups:rules:remove rule_id [rule_id...]", "Remove security group rules."
      long_desc <<-DESC
  Remove the specified security group rules.  More than one rule may be specified on the command line.

Examples:
  hpcloud securitygroups:rules:remove 6686fc56  # Remove the rule `6686fc56`
  hpcloud securitygroups:rules:remove 6686fc56 2ffc3a4c # Remove the rule `6686fc56` and `2ffc3a4c`

Aliases: securitygroups:rules:rm, securitygroups:rules:revoke, securitygroups:rules:delete, securitygroups:rules:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:rules:remove" do |*rule_ids|
        cli_command(options) {
          rule_ids.each { |rule_id|
            sub_command("removing security group rule") {
              Connection.instance.network.delete_security_group_rule(rule_id)
              @log.display "Removed rule '#{rule_id}'."
            }
          }
        }
      end
    end
  end
end
