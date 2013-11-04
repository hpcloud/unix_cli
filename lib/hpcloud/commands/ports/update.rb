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

      desc "ports:update <name>", "Update a port."
      long_desc <<-DESC
  Update fixed IPs, administrative state, device identifier, or device owner on a port in your network.

Examples:
  hpcloud ports:update porto -u -d trump # Update 'porto' administrative status and device owner
  hpcloud ports:update c14411d7 -u -d trump # Update 'c14411d7' administrative status and device owner
      DESC
      method_option :fixedips,
                    :type => :string, :aliases => '-f',
                    :desc => 'Fixed IPs.'
      method_option :adminstate, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      method_option :deviceid,
                    :type => :string, :aliases => '-d',
                    :desc => 'Device ID.'
      method_option :deviceowner,
                    :type => :string, :aliases => '-o',
                    :desc => 'Device owner.'
      CLI.add_common_options
      define_method "ports:update" do |name|
        cli_command(options) {
          port = Ports.new.get(name)
          if port.is_valid? == false
            @log.fatal port.cstatus
          end

          port.set_fixed_ips(options[:fixedips])
          port.set_admin_state(options[:adminstate])
          port.set_device_id(options[:deviceid])
          port.set_device_owner(options[:deviceowner])
          if port.save == true
            @log.display "Updated port '#{name}' with id '#{port.id}'."
          else
            @log.fatal port.cstatus
          end
        }
      end
    end
  end
end
