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

      desc "routers:update <name>", "Update the specified router."
      long_desc <<-DESC
  Update an existing router with new administrative state or gateway infomration.  If you do not want an external network, use the gateway option with an empty string.

Examples:
  hpcloud routers:update trout -u # Update router 'trout' administrative state
  hpcloud routers:update c14411d7 -u # Update router 'c14411d7' administrative state
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Network to use as external router.'
      method_option :adminstateup,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:update" do |name|
        cli_command(options) {
          router = Routers.new.get(name)
          unless options[:adminstateup].nil?
            if options[:adminstateup] == true
              router.admin_state_up = true
            else
              router.admin_state_up = "false"
            end
          end
          router.external_gateway_info = nil
          unless options[:gateway].nil?
            netty = Routers.parse_gateway(options[:gateway])
            if netty.nil?
              router.external_gateway_info = {}
            else
              router.external_gateway_info = { 'network_id' => netty.id }
            end
          end
          router.save
          @log.display "Updated router '#{name}'."
        }
      end
    end
  end
end
