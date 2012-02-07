module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:add <key_name> <fingerprint> <private_key>", "add a key pair"
      long_desc <<-DESC
  Add a key pair by specifying the name. Optionally you can specify a fingerprint and private key data too.
  Additionally you can use the -o option to save the key into a file.

Examples:
  hpcloud keypairs:add mykey
  hpcloud keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66
  hpcloud keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66 'private key data'
  hpcloud keypairs:add mykey -o               # creates a file mykey.pem in the current folder

Aliases: none
      DESC
      method_option :output, :default => false, :type => :boolean, :aliases => '-o', :desc => 'Save the key pair to a file in the current folder.'
      define_method "keypairs:add" do |key_name, fingerprint=nil, private_key=nil|
        begin
          compute_connection = connection(:compute)
          keypair = compute_connection.key_pairs.create(:name => key_name, :fingerprint => fingerprint, :private_key => private_key)
          if options.output?
            keypair.write("./#{keypair.name}.pem")
            display "Created key pair '#{key_name}' and saved it in a file at './#{keypair.name}.pem'."
          else
            display keypair.private_key
            display "Created key pair '#{key_name}'."
          end
        rescue Fog::Compute::HP::Error
          display "Key pair '#{key_name}' already exists."
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end