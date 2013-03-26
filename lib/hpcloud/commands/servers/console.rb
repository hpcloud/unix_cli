module HP
  module Cloud
    class CLI < Thor

      desc "servers:console <server_name_or_id> [lines]", "Get the console output of a server or extract the windows password."
      long_desc <<-DESC
  Display the console output of a server.  When the `-p` option is used with the private key file for the server, if the decrypted password is still available on the console, it is displayed. 

Examples:
  hpcloud servers:console my-server 100         # Display 100 lines of console ouput:
  hpcloud servers:console winserver -p win.pem  # Display the password of the winserver:
      DESC
      method_option :private_key_file,
                    :type => :string, :aliases => '-p',
                    :desc => 'Private key pem file used to decrypt windows password.'
      method_option :dump_password,
                    :type => :boolean, :aliases => '-d',
                    :desc => 'Dump the windows password if the private key is known by the CLI.'
      CLI.add_common_options
      define_method "servers:console" do |name_or_id, *lines|
        cli_command(options) {
          lines = ["50"] if lines.nil? || lines.empty?
          lines = lines[0]
          if lines.match(/[^0-9]/)
            @log.fatal "Invalid number of lines specified '#{lines}'", :incorrect_usage
          end
          lines = lines.to_i + 1
          lines = lines.to_s
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            key_file = options[:private_key_file]
            if key_file.nil?
              unless options[:dump_password].nil?
                key_file = KeypairHelper.private_filename("#{server.id}")
                unless File.exists?(key_file)
                  @log.fatal "Cannot find private key file for '#{name_or_id}'.", :not_found
                end
              end
            end
            if key_file.nil?
              output = server.fog.console_output(lines)
              if output.nil?
                @log.fatal "Error getting console response from #{name_or_id}"
              end
              @log.display "Console output for #{name_or_id}:"
              @log.display output.body["output"]
            else
              server.set_private_key(key_file)
              server.set_image(server.image)
              @log.display "Warning: Server does not appear to be a Windows server" unless server.is_windows?
              @log.display server.windows_password(1)
            end
          else
            @log.fatal server.cstatus
          end
        }
      end
    end
  end
end
