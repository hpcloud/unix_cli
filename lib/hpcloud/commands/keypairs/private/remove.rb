module HP
  module Cloud
    class CLI < Thor

      map %w(keypairs:private:rm keypairs:private:delete keypairs:private:destroy keypairs:private:del) => 'keypairs:private:remove'

      desc "keypairs:private:remove <key_name> [key_name...]", "Make a private key available for the CLI"
      long_desc <<-DESC
  This command copies the private key file to ~/.hpcloud/keypairs directory so the CLI can use it for various commands to access servers.  This command does *not* upload the private key anywhere and it will *only* be available for the CLI on the current server.

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
            filename = keypair.private_remove
            display "Removed private key '#{filename}'."
          }
        }
      end
    end
  end
end
