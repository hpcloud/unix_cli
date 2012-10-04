module HP
  module Cloud
    class CLI < Thor

      desc "servers:reboot name_or_id [name_or_id ...]", "reboot servers specified by server name or id"
      long_desc <<-DESC
  Reboot an existing server specified name or id. Rebooting a server may take some time
  so it might be necessary to check the status of the server by issuing command,
  'hpcloud servers'. By default, a soft reboot is done, but you can specify the -h option to
  do a hard reboot. Optionally, an availability zone can be passed.

Examples:
  hpcloud servers:reboot Hal9000    # reboot 'Hal9000'
  hpcloud servers:reboot 1003 222   # reboot server with id 1003 and 222
  hpcloud servers:reboot DeepThought -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :hard, :default => false,
                    :type => :boolean, :aliases => '-h',
                    :desc => 'Hard reboot a server.'
      CLI.add_common_options
      define_method "servers:reboot" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          servers = Servers.new.get(name_or_ids, false)
          servers.each { |server|
            begin
              if server.is_valid?
                if options.hard?
                  server.fog.reboot("HARD")
                  display "Hard rebooting server '#{server.name}'."
                else
                  server.fog.reboot
                  display "Soft rebooting server '#{server.name}'."
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
