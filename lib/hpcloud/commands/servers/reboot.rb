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
      CLI.add_common_options()
      define_method "servers:reboot" do |name|
        cli_command(options) {
          compute_connection = connection(:compute, options)
          server = compute_connection.servers.select {|s| s.name == name}.first
          if server
            if options.hard?
              server.reboot("HARD")
              display "Hard rebooting server '#{name}'."
            else
              server.reboot
              display "Soft rebooting server '#{name}'."
            end
          else
            error "You don't have a server '#{name}'.", :not_found
          end
        }
      end
    end
  end
end
