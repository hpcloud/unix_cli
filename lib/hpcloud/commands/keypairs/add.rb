module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:add <key_name>", "add a key pair"
      long_desc <<-DESC
  Add a key pair by specifying the name. Optionally you can specify a fingerprint and private key data too.
  Additionally you can use the -o option to save the key into a file. Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs:add mykey                                           # creates a key 'mykey'
  hpcloud keypairs:add mykey -f <fingerprint>                          # creates a key 'mykey' using the supplied fingerprint
  hpcloud keypairs:add mykey -p 'private key data'                     # creates a key 'mykey' using the supplied private key data
  hpcloud keypairs:add mykey -f <fingerprint> -p 'private key data'    # creates a key 'mykey' using the supplied fingerprint and private key data
  hpcloud keypairs:add mykey -o                                        # creates a key and saves it to mykey.pem file in the current folder
  hpcloud keypairs:add mykey -z az-2.region-a.geo-1                    # optionally specify an availability zone

Aliases: none
      DESC
      method_option :fingerprint,
                    :type => :string, :aliases => '-f',
                    :desc => 'Specify a fingerprint to be used.'
      method_option :private_key,
                    :type => :string, :aliases => '-p',
                    :desc => 'Specify private key data to be used.'
      method_option :output, :default => false,
                    :type => :boolean, :aliases => '-o',
                    :desc => 'Save the key pair to a file in the current folder.'
      CLI.add_common_options()
      define_method "keypairs:add" do |key_name|
        begin
          # get the options
          fingerprint = options[:fingerprint]
          private_key = options[:private_key]
          # connect
          compute_connection = connection(:compute, options)
          kp = compute_connection.key_pairs.select {|k| k.name == key_name}.first
          if (kp && kp.name == key_name)
            error "Key pair '#{key_name}' already exists.", :general_error
          else
            keypair = compute_connection.key_pairs.create(:name => key_name, :fingerprint => fingerprint, :private_key => private_key)
            if options.output?
              keypair.write("./#{keypair.name}.pem")
              display "Created key pair '#{key_name}' and saved it to a file at './#{keypair.name}.pem'."
            else
              display keypair.private_key
              display "Created key pair '#{key_name}'."
            end
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error, Excon::Errors::BadRequest => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::Conflict, Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        rescue Excon::Errors::RequestEntityTooLarge => error
          display_error_message(error, :rate_limited)
        end
      end

    end
  end
end
