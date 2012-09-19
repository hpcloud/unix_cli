module HP
  module Cloud
    class CLI < Thor

      desc "volumes:add <name> <size>", "add a volume"
      long_desc <<-DESC
  Add a new volume to your compute account with the specified name and size.  Optionally, a description, metadata or availability zone may be specified.

Examples:
  hpcloud volumes:add :my_volume 10               # Creates a new volume named 'my_volume' of size 10
  hpcloud volumes:add :my_volume 10 -d 'test vol' # Creates a new volume named 'my_volume' of size 10 with a description

Aliases: none
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the volume.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      CLI.add_common_options
      define_method "volumes:add" do |name, size|
        cli_command(options) {
          if Volumes.new.get(name).is_valid? == true
            error "Volume with the name '#{name}' already exists", :general_error
          end
          vol = HP::Cloud::VolumeHelper.new(Connection.instance)
          vol.name = name
          vol.size = size
          vol.description = options[:description]
          vol.meta.set_metadata(options[:metadata])
          if vol.save == true
            display "Created volume '#{name}' with id '#{vol.id}'."
          else
            error(vol.error_string, vol.error_code)
          end
        }
      end
    end
  end
end
