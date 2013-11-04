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

      desc "keypairs:add <key_name>", "add a key pair"
      long_desc <<-DESC
  Add a key pair by specifying the name. Optionally you can specify a fingerprint and private key data. You can use the `-o` option to save the key to a file. Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs:add mykey                                           # Create the key 'mykey'
  hpcloud keypairs:add mykey -f <fingerprint>                          # Create the key 'mykey' using the supplied fingerprint
  hpcloud keypairs:add mykey -p 'private key data'                     # Create the key 'mykey' using the supplied private key data
  hpcloud keypairs:add mykey -f <fingerprint> -p 'private key data'    # Create the key 'mykey' using the supplied fingerprint and private key data
  hpcloud keypairs:add mykey -o                                        # Create the key `mykey` and save it to file `mykey.pem`  in the current folder
  hpcloud keypairs:add mykey -z az-2.region-a.geo-1                    # Create the key `mykey` for availability zone `az-2.region-a.geo-1`
      DESC
      method_option :fingerprint,
                    :type => :string, :aliases => '-f',
                    :desc => 'Specify a fingerprint to be used.'
      method_option :private_key,
                    :type => :string, :aliases => '-p',
                    :desc => 'Specify private key data to be used.'
      method_option :output, :default => true,
                    :type => :boolean, :aliases => '-o',
                    :desc => 'Save key pair in the ~/.hpcloud/keypairs folder.'
      CLI.add_common_options
      define_method "keypairs:add" do |key_name|
        cli_command(options) {
          if Keypairs.new.get(key_name).is_valid? == true
            @log.fatal "Key pair '#{key_name}' already exists.", :conflicted
          end

          keypair = KeypairHelper.new(Connection.instance)
          keypair.name = key_name
          keypair.fingerprint = options[:fingerprint]
          keypair.private_key = options[:private_key]
          if keypair.save == true
            if options.output?
              filename = keypair.private_add
              @log.display "Created key pair '#{key_name}' and saved it to a file at '#{filename}'."
            else
              @log.display keypair.fog.private_key
              @log.display "Created key pair '#{key_name}'."
            end
          else
            @log.fatal keypair.cstatus
          end
        }
      end
    end
  end
end
