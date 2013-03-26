module HP
  module Cloud
    class CLI < Thor

      map %w(snapshots:rm snapshots:delete snapshots:del) => 'snapshots:remove'

      desc "snapshots:remove <name_or_id> [name_or_id ...]", "Remove a snapshot or snapshots (specified by name or ID)."
      long_desc <<-DESC
  Remove snapshots by specifying their names or ID. Optionally, you can specify an availability zone.

Examples:
  hpcloud snapshots:remove snappy1 snappy2                # Delete the snapshots `snappy1` and `snappy2`:
  hpcloud snapshots:remove 998                            # Delete snapshot with the ID 998:
  hpcloud snapshots:remove snappy -z az-2.region-a.geo-1  # Delete snapshot `snappy` for availability zone `az-2.region-a.geo-1`:

Aliases: snapshots:rm, snapshots:delete, snapshots:del
      DESC
      CLI.add_common_options
      define_method "snapshots:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          snapshots = Snapshots.new.get(name_or_ids, false)
          snapshots.each { |snapshot|
            sub_command("removing snapshot") {
              if snapshot.is_valid?
                snapshot.destroy
                @log.display "Removed snapshot '#{snapshot.name}'."
              else
                @log.error snapshot.cstatus
              end
            }
          }
        }
      end
    end
  end
end
