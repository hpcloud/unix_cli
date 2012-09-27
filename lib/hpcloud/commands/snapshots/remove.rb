module HP
  module Cloud
    class CLI < Thor

      map %w(snapshots:rm snapshots:delete snapshots:del) => 'snapshots:remove'

      desc "snapshots:remove <name_or_id> [name_or_id ...]", "remove a snapshots by id or name"
      long_desc <<-DESC
  Remove snapshots by specifying their names or ids. Optionally, an availability zone may be passed.

Examples:
  hpcloud snapshots:remove snappy1 snappy2                # delete two snapshots snappy1 and snappy2
  hpcloud snapshots:remove 998                            # delete snapshot by id 998
  hpcloud snapshots:remove snappy -z az-2.region-a.geo-1  # delete snapshot snappy with availability zone specified

Aliases: snapshots:rm, snapshots:delete, snapshots:del
      DESC
      CLI.add_common_options
      define_method "snapshots:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          snapshots = Snapshots.new.get(name_or_ids, false)
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
