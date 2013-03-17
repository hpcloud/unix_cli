module HP
  module Cloud
    class CLI < Thor
    
      desc "containers:sync name key [location]", "Allow container synchronization."
      long_desc <<-DESC
  Allow container synchronization using the specified key.  If you are creating a destination for synchronization, only the key should be specified.  If you are creating a source for synchronization, specify a key and location.  The same key must be used in the source and destination.  It is possible have containers as both a source and destination.  List your synchronization information with the "hpcloud list --sync" command.

Examples:
  hpcloud containers:sync :atainer keyo   # Set up the container :atainer to be a destination for synchronization
  hpcloud containers:sync :btainer keyo https://region-a.geo-1.objects.hpcloudsvc.com:443/v1/96XXXXXX/atainer     # Synchronize :btainer to remote container :atainer
  hpcloud containers:sync :atainer keyo https://region-b.geo-1.objects.hpcloudsvc.com:443/v1/96XXXXXX/btainer     # Create a two way synchronization betwee :atainer and :btainer
      DESC
      CLI.add_common_options
      define_method "containers:sync" do |name, key, *location|
        cli_command(options) {
          if location.empty?
            location = nil
          else
            location = location[0]
          end
          sub_command("syncing container") {
            res = ContainerResource.new(Connection.instance.storage, name)
            if res.sync(key, location)
              if location.nil?
                @log.display "Container #{name} using key '#{key}'"
              else
                @log.display "Container #{name} using key '#{key}' to #{location}"
              end
            else
              @log.error res.cstatus
            end
          }
        }
      end
    end
  end
end
