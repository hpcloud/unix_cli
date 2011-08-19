module HP
  module Cloud
    class CLI < Thor

      map %w(keypairs:delete keypairs:del) => 'keypairs:remove'

      desc "keypairs:remove <key_name>", "remove a key pair by name"
      long_desc <<-DESC
  Remove an existing key pair by name.

Examples:
  hpcloud keypairs:remove mykey

Aliases: keypairs:delete, keypairs:del
      DESC
      define_method "keypairs:remove" do |key_name|
        begin
          compute_connection = connection(:compute)
          keypair = compute_connection.key_pairs.select {|k| k.name == key_name}.first
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
        if (keypair && keypair.name == key_name)
          begin
            keypair.destroy
            display "Removed key pair '#{key_name}'."
          rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
            display_error_message(error)
          end
        else
          error "You don't have a key pair with '#{key_name}'.", :not_found
        end
      end

    end
  end
end