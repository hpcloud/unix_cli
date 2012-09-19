module HP
  module Cloud
    class CLI < Thor

      map %w(snapshots:rm snapshots:delete snapshots:del) => 'snapshots:remove'

      desc "snapshots:remove <id|name> ...", "remove a snapshot by id or name"
      long_desc <<-DESC
  Remove snapshots by specifying their names or ids. Optionally, an availability zone may be passed.

Examples:
  hpcloud snapshots:remove my-snapshot 998                     # delete 'my-snapshot' and 998
  hpcloud snapshots:remove my-snapshot -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: snapshots:rm, snapshots:delete, snapshots:del
      DESC
      CLI.add_common_options
      define_method "snapshots:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          snapshots = Snapshots.new.get(names, false)
          snapshots.each { |snapshot|
            begin
              if snapshot.is_valid?
                snapshot.destroy
                display "Removed snapshot '#{snapshot.name}'."
              else
                error_message(snapshot.error_string, snapshot.error_code)
              end
            rescue Exception => e
              error_message("Error removing snapshot: " + e.to_s, :general_error)
            end
          }
        }
      end
    end
  end
end
