module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:import <key_name> <public_key_data>", "import a key pair"
      long_desc <<-DESC
  Import a key pair by specifying the public key data.

Examples:
  hpcloud keypairs:import mykey public_key_data

Aliases: none
      DESC
      define_method "keypairs:import" do |key_name, public_key_data|
        begin
          compute_connection = connection(:compute)
          keypair = compute_connection.import_key_pair(key_name, public_key_data)
          display "Imported key pair '#{key_name}'."
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end