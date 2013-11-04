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

      desc "servers:add <name> <flavor>", "Add a server."
      long_desc <<-DESC
  Add a new server to your compute account. You must specify:  Server name, a flavor, an image or volume to use, and a key pair.  If you are creating a windows server, the flavor must be at least a large and you must specify a security group that has the RDP port open.  Optionally, you can specify a security group, key name, metadata and availability zone.

Examples:
  hpcloud servers:add my_server small -i 90ea5676 -k key1          # Create a new small server named 'my_server' with image 90ea5676 and key1
  hpcloud servers:add winserv large -i c80dfe05 -k winpair -s allowsRDP -p ./winpair.pem # Create a windows server with the specified key, security group, and private key to decrypt the password
  hpcloud servers:add my_server large -v natty -k key1 -s sg1   # Create a new large server named 'my_server' using volume `natty`, key `key1`, and the `sg1` security group
  hpcloud servers:add my_server small -i 53e78869 -k key1 -m this=that     # Create a new small server named 'my_server' using the specified image, flavor, key and metadata this=that
  hpcloud servers:add my_server large -i 53e78869 -k key1 --personality rootdir     # Create 'my_server' with the personality specified in the directory 'rootdir'
      DESC
      method_option :key_name, :required => true,
                    :type => :string, :aliases => '-k',
                    :desc => 'Specify a key name to be used.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Image to use to create the server.'
      method_option :volume,
                    :type => :string, :aliases => '-v',
                    :desc => 'Volume to use to create the server.'
      method_option :security_group,
                    :type => :string, :aliases => '-s',
                    :desc => 'Specify a security group or comma seperated list of security groups to be used.'
      method_option :private_key_file,
                    :type => :string, :aliases => '-p',
                    :desc => 'Name of the pem file with your private key.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      method_option :network,
                    :type => :string, :aliases => '-n',
                    :desc => 'Network to use for the server.'
      method_option :userdata,
                    :type => :string, :aliases => '-u',
                    :desc => 'File which contains user data.'
      method_option :personality,
                    :type => :string,
                    :desc => 'Directory containing personality for server.'
      CLI.add_common_options
      define_method "servers:add" do |name, *flavor|
        cli_command(options) {
          srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
          srv.name = name
          srv.set_flavor(flavor.first) unless flavor.first.nil?
          srv.set_image(options[:image])
          srv.set_volume(options[:volume])
          srv.set_keypair(options[:key_name])
          srv.set_security_groups(options[:security_group])
          srv.set_private_key(options[:private_key_file])
          srv.meta.set_metadata(options[:metadata])
          srv.set_network(options[:network])
          srv.set_user_data(options[:userdata])
          srv.set_personality(options[:personality])
          if srv.save == true
            @log.display "Created server '#{name}' with id '#{srv.id}'."
            if srv.is_windows?
              unless srv.is_private_image?
                @log.display "Retrieving password, this may take several minutes..."
                srv.fog.wait_for { ready? }
                @log.display "Windows password: " + srv.windows_password
                @log.display "Make sure the security group has RDP port 3389 open"
                @log.display "You may wish to change the password when you log in"
                if srv.is_valid? == false
                  @log.fatal srv.cstatus
                end
              end
            end
          else
            @log.fatal srv.cstatus
          end
        }
      end
    end
  end
end
