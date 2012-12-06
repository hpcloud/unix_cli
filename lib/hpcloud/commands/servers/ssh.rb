require 'net/ssh'

module HP
  module Cloud
    class CLI < Thor

      desc "servers:ssh <server_name_or_id>", "Secure shell into the server."
      long_desc <<-DESC
  Secure shell into the server.

Examples:
  hpcloud servers:console bugs -p bunny.pem  # Secure shell into the bugs server
  hpcloud servers:console daffy              # Secure shell into daffy which has a know keypair
      DESC
      method_option :private_key_file,
                    :type => :string, :aliases => '-p',
                    :desc => 'Name of the pem file with your private key.'
      method_option :keypair,
                    :type => :string, :aliases => '-k',
                    :desc => 'Name of keypair to use.'
      method_option :login,
                    :type => :string, :aliases => '-l',
                    :default => 'ubuntu',
                    :desc => 'Login id to use.'
      CLI.add_common_options
      define_method "servers:ssh" do |name_or_id|
        cli_command(options) {
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            keypair = KeypairHelper.new(nil)
            keypair.name = options[:keypair]
            filename = keypair.private_filename
            loginid = options[:login]
            puts("ssh #{loginid}@#{server.public_ip} -i #{filename}")
          else
            error server.error_string, server.error_code
          end
        }
      end
    end
  end
end
