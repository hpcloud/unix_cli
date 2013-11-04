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

require 'hpcloud/commands/keypairs/import'
require 'hpcloud/commands/keypairs/add'
require 'hpcloud/commands/keypairs/remove'

module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:public_key <name>", "Display the public keys of a key pair."
      long_desc <<-DESC
  Display the public key of the specified keypair.  Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs:public_key keyno                # Remove the public key `keyno`
  hpcloud keypairs:public_key keyno -z az-2.region-a.geo-1    # Remove the public key `keyno` for availability zone `az-2.region-a.geo-1`
      DESC
      CLI.add_common_options
      define_method "keypairs:public_key" do |key_name|
        cli_command(options) {
          keypair = Keypairs.new.get(key_name)
          unless keypair.is_valid?
            @log.fatal keypair.cstatus
          end

          @log.display keypair.public_key
        }
      end
    end
  end
end
