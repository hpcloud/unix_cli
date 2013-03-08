module HP
  module Cloud
    class CLI < Thor

      desc "lbaas:add <name> [size]", "Add a lbaas."
      long_desc <<-DESC
  Add a new load balancer in your account with the specified name and size.  Optionally, you can specify a description, metadata or availability zone.  If you do not specify a size, it is taken from the specified snapshot or image.  If no image or snapshot is specified, the size defaults to 1 gigabyte.

Examples:
  hpcloud lbaas:add my_lbaas 10               # Create a new lbaas named 'my_lbaas' of size 10:
  hpcloud lbaas:add my_lbaas 10 -d 'test lbs' # Create a new lbaas named 'my_lbaas' of size 10 with a description:
  hpcloud lbaas:add my_lbaas -s 'snappy'      # Create a new lbaas named 'my_lbaas' based on the snapshot 'snappy':
  hpcloud lbaas:add my_lbaas -i 20103         # Create a new bootable lbaas named 'my_lbaas' based on the image '20103':
  hpcloud lbaas:add my_lbaas 1 -z az-2.region-a.geo-1 # Creates lbaas `my_lbaas` in availability zone `az-2.region-a.geo-1`:
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the lbaas.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the metadata.'
      method_option :snapshot,
                    :type => :string, :aliases => '-s',
                    :desc => 'Create a lbaas from the specified snapshot.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Create a lbaas from the specified image.'
      CLI.add_common_options
      define_method "lbaas:add" do |name, *lbaas_size|
        cli_command(options) {
          if Lbaass.new.get(name).is_valid? == true
            @log.fatal "Lbaas with the name '#{name}' already exists"
          end
          lbs = HP::Cloud::LbaasHelper.new(Connection.instance)
          lbs.name = name
          lbs.size = lbaas_size.first
          unless options[:snapshot].nil?
            snapshot = HP::Cloud::Snapshots.new.get(options[:snapshot])
            if snapshot.is_valid?
              lbs.snapshot_id = snapshot.id.to_s
              lbs.size = snapshot.size.to_s if lbs.size.nil?
            else
              @log.fatal snapshot.cstatus
            end
          end
          unless options[:image].nil?
            image = HP::Cloud::Images.new.get(options[:image])
            if image.is_valid?
              lbs.imageref = image.id.to_s
            else
              @log.fatal image.cstatus
            end
          end
          lbs.size = 1 if lbs.size.nil?
          lbs.description = options[:description]
          if lbs.save == true
            @log.display "Created lbaas '#{name}' with id '#{lbs.id}'."
          else
            @log.fatal lbs.cstatus
          end
        }
      end
    end
  end
end
