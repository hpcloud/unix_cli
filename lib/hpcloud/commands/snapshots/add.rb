module HP
  module Cloud
    class CLI < Thor

      desc "snapshots:add <name> <volume>", "create a snapshot"
      long_desc <<-DESC
  Create a snapshot from the volume with the given name.  Optionally, a description may be specified.

Examples:
  hpcloud snapshots:add my_snapshot vol10               # Creates a new snapshot named 'my_snapshot' from the specified volume
  hpcloud snapshots:add my_snapshot vol10 -d 'test vol' # Creates a new snapshot named 'my_snapshot' from the specified volume

Aliases: none
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the snapshot.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      CLI.add_common_options
      define_method "snapshots:add" do |name, volume_name_id|
        cli_command(options) {
          if Snapshots.new.get(name).is_valid? == true
            error "Snapshot with the name '#{name}' already exists", :general_error
          end
          vol = HP::Cloud::SnapshotHelper.new(Connection.instance)
          vol.name = name
          vol.description = options[:description]
          if vol.set_volume(volume_name_id)
            if vol.save == true
              display "Created snapshot '#{name}' with id '#{vol.id}'."
            else
              error(vol.error_string, vol.error_code)
            end
          else
            error "Cannot find volume '#{volume_name_id}'", :general_error
          end
        }
      end
    end
  end
end
