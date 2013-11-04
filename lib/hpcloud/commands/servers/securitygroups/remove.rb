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

      desc "servers:securitygroups:remove <server> <security_groups>", "Remove a security group from a server."
      long_desc <<-DESC
  Remove a security group from a server.

Examples:
  hpcloud servers:securitygroups:remove my_server sg2   # Remove security group 'sg2' from 'my_server'
      DESC
      CLI.add_common_options
      define_method "servers:securitygroups:remove" do |name_or_id, security_group|
        cli_command(options) {
          srv = Servers.new.get(name_or_id)
          if srv.is_valid?
            srv.remove_security_groups(security_group)
            @log.display "Removed security group '#{security_group}' from server '#{name_or_id}'."
          else
            @log.fatal srv.cstatus
          end
        }
      end
    end
  end
end
