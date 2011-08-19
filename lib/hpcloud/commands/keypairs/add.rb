module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:add <key_name> <fingerprint> <private_key>", "add a key pair"
      long_desc <<-DESC
  Add a key pair by specifying the fingerprint and private key data.

Examples:
  hpcloud keypairs:add mykey
  hpcloud keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66
  hpcloud keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66 'private key data'

Aliases: none
      DESC
      define_method "keypairs:add" do |key_name, fingerprint=nil, private_key=nil|
        begin
          compute_connection = connection(:compute)
          keypair = compute_connection.key_pairs.create(:name => key_name, :fingerprint => fingerprint, :private_key => private_key)
          display keypair.private_key
          display "Created key pair '#{key_name}'."
        rescue Fog::AWS::Compute::Error
          display "Key pair '#{key_name}' already exists."
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end