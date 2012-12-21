module HP
  module Cloud
    class CLI < Thor

      desc "servers:ssh <server_name_or_id>", "Secure shell into the server."
      long_desc <<-DESC
  Log in using the secure shell to the designated server.

Examples:
  hpcloud servers:console bugs -p bunny.pem  # Use the secure shell to log in to the bugs server:
  hpcloud servers:console daffy              # Use the secure shell to log in to server `daffy`, which has a know keypair
      DESC
      method_option :private_key_file,
                    :type => :string, :aliases => '-p',
                    :desc => 'Name of the pem file with your private key.'
      method_option :keypair,
                    :type => :string, :aliases => '-k',
                    :desc => 'Name of keypair to use.'
      method_option :login,
                    :type => :string, :aliases => '-l',
                    :desc => 'Login id to use.'
      method_option :command,
                    :type => :string, :aliases => '-c',
                    :default => 'ssh',
                    :desc => 'Command to use to connect.'
      CLI.add_common_options
      define_method "servers:ssh" do |name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            unless options[:keypair].nil?
              filename = KeypairHelper.private_filename(options[:keypair])
            end
            unless options[:private_key_file].nil?
              filename = options[:private_key_file]
            end
            if filename.nil?
              filename = KeypairHelper.private_filename("#{server.id}")
              if File.exists?(filename) == false
                @log.fatal "There is no local configuration to determine what private key is associated with this server.  Use the keypairs:private:add command to add a key named #{server.id} for this server or use the -k or -p option.", :incorrect_usage
              end
            end
            loginid = options[:login]
            if loginid.nil?
              image = Images.new.get(server.image)
              if image.is_valid?
                loginid = image.login
              else
                loginid = "ubuntu"
              end
            end
            command = options[:command]
            @log.display "Connecting to '#{name_or_id}'..."
            system("#{command} #{loginid}@#{server.public_ip} -i #{filename}")
          else
            @log.fatal server.error_string, server.error_code
          end
        }
      end
    end
  end
end
