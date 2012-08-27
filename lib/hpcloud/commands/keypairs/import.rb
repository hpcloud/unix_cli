module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:import <key_name> <public_key_data>", "import a key pair"
      long_desc <<-DESC
  Import a key pair by specifying the public key data. Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs:import mykey 'public_key_data'                          # import a key from public key data
  hpcloud keypairs:import mykey 'public_key_data' -z az-2.region-a.geo-1   # optionally specify an availability zone

Aliases: none
      DESC
      CLI.add_common_options()
      define_method "keypairs:import" do |key_name, public_key_data|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          keypair = compute_connection.key_pairs.select {|k| k.name == key_name}.first
          if (keypair && keypair.name == key_name)
            error "Key pair '#{key_name}' already exists.", :general_error
          else
            compute_connection.create_key_pair(key_name, public_key_data)
            display "Imported key pair '#{key_name}'."
          end
        }
      end
    end
  end
end
