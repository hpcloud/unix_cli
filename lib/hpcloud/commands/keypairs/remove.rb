module HP
  module Cloud
    class CLI < Thor

      map %w(keypairs:rm keypairs:delete keypairs:del) => 'keypairs:remove'

      desc "keypairs:remove name [name ...]", "Remove a key pair (by name)."
      long_desc <<-DESC
  Remove an existing key pair by name. You may specify more than one key pair to remove on a single command line.  Optionally, you can specify an availability zone.

Examples:
  hpcloud keypairs:remove mykey             # Remove the key pair 'mykey':
  hpcloud keypairs:remove mykey myotherkey  # Remove the key pairs 'mykey' and 'myotherkey':
  hpcloud keypairs:remove mykey -z az-2.region-a.geo-1  # Remove the key pair `mykey` for availability zone `az-2.region-a.geo-1:

Aliases: keypairs:rm, keypairs:delete, keypairs:del
      DESC
      CLI.add_common_options
      define_method "keypairs:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          keypairs = Keypairs.new.get(names, false)
          keypairs.each { |keypair|
            sub_command("removing keypair") {
              if keypair.is_valid?
                keypair.destroy
                @log.display "Removed key pair '#{keypair.name}'."
              else
                @log.error keypair.cstatus
              end
            }
          }
        }
      end
    end
  end
end
