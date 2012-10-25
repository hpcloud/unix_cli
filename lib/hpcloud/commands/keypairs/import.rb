module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:import <key_name> <public_key_data>", "Import a key pair."
      long_desc <<-DESC
  Import a key pair by specifying the public key data. Alternately, you may specify the name of the file to import on the command line.  Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs:import mykey ~/.ssh/id_rsa.pub    # import a key from file
  hpcloud keypairs:import mykey 'public_key_data'    # import a key from public key data
  hpcloud keypairs:import mykey 'public_key_data' -z az-2.region-a.geo-1   # optionally specify an availability zone
      DESC
      CLI.add_common_options
      define_method "keypairs:import" do |key_name, public_key_data|
        cli_command(options) {
          keypair = Keypairs.new.get(key_name)
          if keypair.is_valid?
            error "Key pair '#{key_name}' already exists.", :general_error
          else
            keypair = KeypairHelper.new(Connection.instance)
            keypair.name = key_name
            begin
              path = File.expand_path(public_key_data)
              if File.exists?(path)
                public_key_data = File.read(path)
              end
            rescue
            end
            keypair.public_key = public_key_data
            if keypair.save == true
              display "Imported key pair '#{key_name}'."
            else
              error keypair.error_string, keypair.error_code
            end
          end
        }
      end
    end
  end
end
