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

      desc "securitygroups:add <name> <description>", "Add a security group."
      long_desc <<-DESC
  Add a new security group by specifying a name and a description. Optionally, you can specify an availability zone.

Examples:
  hpcloud securitygroups:add mysecgroup "seg group desc"  # Add new security group `mysecgroup` with description `seg group desc`
      DESC
      CLI.add_common_options
      define_method "securitygroups:add" do |sec_group_name, sg_desc|
        cli_command(options) {
          if SecurityGroups.new.get(sec_group_name).is_valid? == true
            @log.fatal "Security group '#{sec_group_name}' already exists."
          end

          security_group = SecurityGroupHelper.new(Connection.instance)
          security_group.name = sec_group_name
          security_group.description = sg_desc
          if security_group.save == true
            @log.display "Created security group '#{sec_group_name}' with id '#{security_group.id}'."
          else
            @log.fatal security_group.cstatus
          end
        }
      end
    end
  end
end
