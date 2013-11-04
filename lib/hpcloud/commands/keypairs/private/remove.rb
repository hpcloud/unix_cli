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

      map %w(keypairs:private:rm keypairs:private:delete keypairs:private:destroy keypairs:private:del) => 'keypairs:private:remove'

      desc "keypairs:private:remove <key_name> [key_name...]", "Remove a private key file"
      long_desc <<-DESC
  This command removes private key files from the ~/.hpcloud/keypairs directory which is the store used by the CLI. If you plan to continue to use this private key, make sure you have it stored somewhere else.  There is no way to recover a private key that has been deleted unless you have another copy of that key.  Keys are stored in the ~/.hpcloud/keypairs directory by key name and server id, so there may be multiple copies of a single key in the private key store.

Examples:
  hpcloud keypairs:private:remove mykey spare  # Remove 'mykey' and 'spare' from the private key storage

Aliases: keypairs:private:rm, keypairs:private:del
      DESC
      define_method "keypairs:private:remove" do |name, *names|
        cli_command(options) {
          keypair = KeypairHelper.new(nil)
          names = [name] + names
          names.each { |name|
            keypair.name = name
            sub_command {
              filename = keypair.private_remove
              @log.display "Removed private key '#{filename}'."
            }
          }
        }
      end
    end
  end
end
