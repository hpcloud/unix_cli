module HP
  module Cloud
    class CLI < Thor

      map %w(keypairs:rm keypairs:delete keypairs:del) => 'keypairs:remove'

      desc "keypairs:remove <key_name>", "remove a key pair by name"
      long_desc <<-DESC
  Remove an existing key pair by name. Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs:remove mykey
  hpcloud keypairs:remove mykey -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: keypairs:rm, keypairs:delete, keypairs:del
      DESC
      CLI.add_common_options
      define_method "keypairs:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          keypairs = Keypairs.new.get(names, false)
          keypairs.each { |keypair|
            begin
              if keypair.is_valid?
                keypair.destroy
                display "Removed key pair '#{keypair.name}'."
              else
                error_message(keypair.error_string, keypair.error_code)
              end
            rescue Exception => e
              error_message("Error removing keypair: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end
