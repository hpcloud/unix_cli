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

      desc "keypairs:import <key_name> <public_key_data>", "Import a key pair."
      long_desc <<-DESC
  Import a key pair by specifying the public key data. Alternately, you may specify the name of the import file on the command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs:import mykey ~/.ssh/id_rsa.pub    # Import a key from file `~/.ssh/id_rs.pub`
  hpcloud keypairs:import mykey 'public_key_data'    # Import a key from public key data
  hpcloud keypairs:import mykey 'public_key_data' -z az-2.region-a.geo-1   # Import a key from public key data for availability zone `az-2.region-a.geo-1`
      DESC
      CLI.add_common_options
      define_method "keypairs:import" do |key_name, public_key_data|
        cli_command(options) {
          keypair = Keypairs.new.get(key_name)
          if keypair.is_valid?
            @log.fatal "Key pair '#{key_name}' already exists."
          else
            keypair = KeypairHelper.new(Connection.instance)
            keypair.name = key_name
            begin
              path = File.expand_path(public_key_data)
              if File.exists?(path)
                public_key_data = File.read(path)
              end
            rescue
            end
            keypair.public_key = public_key_data
            if keypair.save == true
              @log.display "Imported key pair '#{key_name}'."
            else
              @log.fatal keypair.cstatus
            end
          end
        }
      end
    end
  end
end
