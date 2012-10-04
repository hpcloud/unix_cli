module HP
  module Cloud
    class CLI < Thor

      desc "servers:reboot <name>", "reboot a server by name"
      long_desc <<-DESC
  Reboot an existing server by specifying its name. Rebooting a server may take some time
  so it might be necessary to check the status of the server by issuing command,
  'hpcloud servers'. By default, a soft reboot is done, but you can specify the -h option to
  do a hard reboot. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:reboot my-server          # reboot 'my-server'
  hpcloud servers:reboot my-server -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :hard, :default => false,
                    :type => :boolean, :aliases => '-h',
                    :desc => 'Hard reboot a server.'
      CLI.add_common_options
      define_method "servers:reboot" do |name, *names|
        cli_command(options) {
          names = [name] + names
          servers = Servers.new.get(names, false)
          servers.each { |server|
            begin
              if server.is_valid?
                if options.hard?
                  server.fog.reboot("HARD")
                  display "Hard rebooting server '#{name}'."
                else
                  server.fog.reboot
                  display "Soft rebooting server '#{name}'."
                end
              else
                error_message server.error_string, server.error_code
              end
            rescue Exception => e
              error_message("Error removing image: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end
