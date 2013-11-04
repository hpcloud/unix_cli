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

      map %w(securitygroups:rm securitygroups:delete securitygroups:del) => 'securitygroups:remove'

      desc "securitygroups:remove name_or_id [name_or_id ...]", "Remove a security group or groups."
      long_desc <<-DESC
  Remove existing security groups by name or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:remove group1 group2 # Remove the security groups `group1` and `group2`
  hpcloud securitygroups:remove 41fb5504      # Remove the security group with the ID `41fb5504`

Aliases: securitygroups:rm, securitygroups:delete, securitygroups:del
      DESC
      CLI.add_common_options
      define_method "securitygroups:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          securitygroups = SecurityGroups.new.get(name_or_ids, false)
          securitygroups.each { |securitygroup|
            sub_command("removing security group") {
              if securitygroup.is_valid?
                securitygroup.destroy
                @log.display "Removed security group '#{securitygroup.name}'."
              else
                @log.error securitygroup.cstatus
              end
            }
          }
        }
      end
    end
  end
end
