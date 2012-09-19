module HP
  module Cloud
    class CLI < Thor

      desc "snapshots:add <name> <size>", "create a snapshot"
      long_desc <<-DESC
  Add a new snapshot to your compute account with the specified name and size.  Optionally, a description, metadata or availability zone may be specified.

Examples:
  hpcloud snapshots:add :my_snapshot 10               # Creates a new snapshot named 'my_snapshot' using an image and flavor \n
  hpcloud snapshots:add :my_snapshot 10 -d 'test vol' # Creates a new snapshot named 'my_snapshot' using an image, flavor and a key \n
  hpcloud snapshots:add :my_snapshot 7 1 -z az-2.region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the snapshot.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      CLI.add_common_options
      define_method "snapshots:add" do |name, volume|
        cli_command(options) {
          if Snapshots.new.get(name).is_valid? == true
            error "Snapshot with the name '#{name}' already exists", :general_error
          end
          vol = HP::Cloud::SnapshotHelper.new(Connection.instance)
          vol.name = name
          vol.size = size
          vol.description = options[:description]
          vol.meta.set_metadata(options[:metadata])
          if vol.save == true
            display "Created snapshot '#{name}' with id '#{vol.id}'."
          else
            error(vol.error_string, vol.error_code)
          end
        }
      end
    end
  end
end
