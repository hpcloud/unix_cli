module HP
  module Cloud
    class CLI < Thor

      desc "servers:console <server_name_or_id> [lines]", "Get the console output of a server or extract the windows password."
      long_desc <<-DESC
  Dump out the console output of a server.  If the -p or -d option is given, the decrypted password will be printed as long as it is still available on the console.

Examples:
  hpcloud servers:console my-server 100         # Get 100 lines of console ouput
  hpcloud servers:console winserver -p win.pem  # Print the password of winserver
  hpcloud servers:console winserver -d          # Print the password of winserver if the private key is known to the CLI
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
            error "Invalid number of lines specified '#{lines}'", :incorrect_usage
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
                  error "Cannot find private key file for '#{name_or_id}'.", :not_found
                end
              end
            end
            if key_file.nil?
              output = server.fog.console_output(lines)
              if output.nil?
                error "Error getting console response from #{name_or_id}", :general_error
              end
              display "Console output for #{name_or_id}:"
              display output.body["output"]
            else
              server.set_private_key(key_file)
              server.set_image(server.image)
              display "Warning: Server does not appear to be a Windows server" unless server.is_windows?
              display server.windows_password(1)
            end
          else
            error server.error_string, server.error_code
          end
        }
      end
    end
  end
end
