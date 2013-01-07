module HP
  module Cloud
    class CLI < Thor

      desc "servers:reboot name_or_id [name_or_id ...]", "Reboot a server or servers (specified by server name or ID)."
      long_desc <<-DESC
  Reboot an existing server specified name or ID. Rebooting a server can take some time so it might be necessary to check the status of the server by issuing the command `hpcloud servers`. The default is a soft reboot, but you can specify the `-h` option for a hard reboot. Optionally, you can specify an availability zone.

Examples:
  hpcloud servers:reboot Hal9000    # Reboot server 'Hal9000':
  hpcloud servers:reboot 1003 222   # Reboot the servers with the IDs 1003 and 222
  hpcloud servers:reboot DeepThought -z az-2.region-a.geo-1    # Reboot the server `DeepThought` for availability zone `az-2.region-a.geo-1`:
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
            sub_command("rebooting server") {
              if server.is_valid?
                if options.hard?
                  server.fog.reboot("HARD")
                  @log.display "Hard rebooting server '#{server.name}'."
                else
                  server.fog.reboot
                  @log.display "Soft rebooting server '#{server.name}'."
                end
              else
                @log.error server.cstatus
              end
            }
          }
        }
      end
    end
  end
end
