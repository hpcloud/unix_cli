require 'hpcloud/commands/keypairs/import'
require 'hpcloud/commands/keypairs/add'
require 'hpcloud/commands/keypairs/remove'

module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:public_key <name>", "dump the public keys of a keypair"
      long_desc <<-DESC
  Dump the public key of the specified keypair.  Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs:public_key keyno                # Dump the keyno public key
  hpcloud keypairs:public_key keyno -z az-2.region-a.geo-1    # Optionally specify an availability zone
      DESC
      CLI.add_common_options
      define_method "keypairs:public_key" do |key_name|
        cli_command(options) {
          keypair = Keypairs.new.get(key_name)
          unless keypair.is_valid?
            error keypair.error_string, keypair.error_code
          end

          display keypair.public_key
        }
      end
    end
  end
end
