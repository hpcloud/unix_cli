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
  hpcloud keypairs:public_key keyno                # Remove the public key `keyno`:
  hpcloud keypairs:public_key keyno -z az-2.region-a.geo-1    # Remove the public key `keyno` for availability zone `az-2.region-a.geo-1`:
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
