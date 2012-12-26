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
