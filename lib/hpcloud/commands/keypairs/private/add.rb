module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:private:add <key_name> <file_name>", "Make a private key available for the CLI"
      long_desc <<-DESC
  This command copies the private key file to ~/.hpcloud/keypairs directory so the CLI can use it for various commands to access servers.  This command does *not* upload the private key anywhere and it will *only* be available for the CLI on the current server.

Examples:
  hpcloud keypairs:private:add mykey ./mykey.pem  # Make the 'mykey' private key available for the CLI
      DESC
      define_method "keypairs:private:add" do |key_name, file_name|
        cli_command(options) {
          keypair = KeypairHelper.new(nil)
          keypair.name = key_name
          keypair.private_key = File.read(file_name)
          filename = keypair.private_add
          @log.display "Added private key '#{filename}'."
        }
      end
    end
  end
end
