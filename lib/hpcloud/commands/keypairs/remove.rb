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
      define_method "keypairs:remove" do |key_name|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          keypair = compute_connection.key_pairs.select {|k| k.name == key_name}.first
          if (keypair && keypair.name == key_name)
            keypair.destroy
            display "Removed key pair '#{key_name}'."
          else
            error "You don't have a key pair with '#{key_name}'.", :not_found
          end
        }
      end
    end
  end
end
