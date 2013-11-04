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

      desc "networks:add <name>", "Add a network."
      long_desc <<-DESC
  Add a new network in your account with the specified name.  Optionally, you can specify administrative state.

Examples:
  hpcloud networks:add netty        # Create a new network named 'netty'
  hpcloud networks:add netty --no-adminstateup  # Create a new network named 'netty' admin state down
      DESC
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state up.'
      CLI.add_common_options
      define_method "networks:add" do |name|
        cli_command(options) {
          if Networks.new.get(name).is_valid? == true
            @log.fatal "Network with the name '#{name}' already exists"
          end
          network = HP::Cloud::NetworkHelper.new(Connection.instance)
          network.name = name
          network.admin_state_up = options[:adminstateup]
          if network.save == true
            @log.display "Created network '#{name}' with id '#{network.id}'."
          else
            @log.fatal network.cstatus
          end
        }
      end
    end
  end
end
