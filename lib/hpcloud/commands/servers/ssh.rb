module HP
  module Cloud
    class CLI < Thor

      desc "servers:ssh <server_name_or_id>", "Secure shell into a server."
      long_desc <<-DESC
  Log in using the secure shell to the specified server.

Examples:
  hpcloud servers:ssh bugs -p bunny.pem  # Use the secure shell to log into the bugs server:
  hpcloud servers:ssh daffy              # Use the secure shell to log into server `daffy`, which has a known key pair
  hpcloud servers:ssh 15.185.104.210     # Use the secure shell to log into server with given public IP, which has a known key pair known to the CLI
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
          servers = Servers.new
          server = servers.get(name_or_id)
          unless server.is_valid?
            result = servers.find_by_ip(name_or_id)
            unless result.nil?
              server = result if result.is_valid?
            end
          end
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
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end
