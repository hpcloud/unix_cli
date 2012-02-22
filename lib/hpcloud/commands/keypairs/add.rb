module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:add <key_name> <fingerprint> <private_key>", "add a key pair"
      long_desc <<-DESC
  Add a key pair by specifying the name. Optionally you can specify a fingerprint and private key data too.
  Additionally you can use the -o option to save the key into a file.

Examples:
  hpcloud keypairs:add mykey                                           # creates a key 'mykey'
  hpcloud keypairs:add mykey -f <fingerprint>                          # creates a key 'mykey' using the supplied fingerprint
  hpcloud keypairs:add mykey -p 'private key data'                     # creates a key 'mykey' using the supplied private key data
  hpcloud keypairs:add mykey -f <fingerprint> -p 'private key data'    # creates a key 'mykey' using the supplied fingerprint and private key data
  hpcloud keypairs:add mykey -o                                        # creates a key and saves it to mykey.pem file in the current folder

Aliases: none
      DESC
      method_option :fingerprint, :type => :string, :aliases => '-f', :desc => 'Specify a fingerprint to be used.'
      method_option :private_key, :type => :string, :aliases => '-p', :desc => 'Specify private key data to be used.'
      method_option :output, :default => false, :type => :boolean, :aliases => '-o', :desc => 'Save the key pair to a file in the current folder.'
      define_method "keypairs:add" do |key_name|
        begin
          # get the options
          fingerprint = options[:fingerprint]
          private_key = options[:private_key]
          # connect
          compute_connection = connection(:compute)
          keypair = compute_connection.key_pairs.create(:name => key_name, :fingerprint => fingerprint, :private_key => private_key)
          if options.output?
            keypair.write("./#{keypair.name}.pem")
            display "Created key pair '#{key_name}' and saved it to a file at './#{keypair.name}.pem'."
          else
            display keypair.private_key
            display "Created key pair '#{key_name}'."
          end
        rescue Fog::Compute::HP::Error
          error "Key pair '#{key_name}' already exists.", :general_error
        rescue Excon::Errors::BadRequest => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end