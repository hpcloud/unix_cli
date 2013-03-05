module HP
  module Cloud
    class CLI < Thor

      desc "dns:add <name> [size]", "Add a dns."
      long_desc <<-DESC
  Add a new load balancer in your account with the specified name and size.  Optionally, you can specify a description, metadata or availability zone.  If you do not specify a size, it is taken from the specified snapshot or image.  If no image or snapshot is specified, the size defaults to 1 gigabyte.

Examples:
  hpcloud dns:add my_dns 10               # Create a new dns named 'my_dns' of size 10:
  hpcloud dns:add my_dns 10 -d 'test dns' # Create a new dns named 'my_dns' of size 10 with a description:
  hpcloud dns:add my_dns -s 'snappy'      # Create a new dns named 'my_dns' based on the snapshot 'snappy':
  hpcloud dns:add my_dns -i 20103         # Create a new bootable dns named 'my_dns' based on the image '20103':
  hpcloud dns:add my_dns 1 -z az-2.region-a.geo-1 # Creates dns `my_dns` in availability zone `az-2.region-a.geo-1`:
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the dns.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the metadata.'
      method_option :snapshot,
                    :type => :string, :aliases => '-s',
                    :desc => 'Create a dns from the specified snapshot.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Create a dns from the specified image.'
      CLI.add_common_options
      define_method "dns:add" do |name, *dns_size|
        cli_command(options) {
          if Dnss.new.get(name).is_valid? == true
            @log.fatal "Dns with the name '#{name}' already exists"
          end
          dns = HP::Cloud::DnsHelper.new(Connection.instance)
          dns.name = name
          dns.size = dns_size.first
          unless options[:snapshot].nil?
            snapshot = HP::Cloud::Snapshots.new.get(options[:snapshot])
            if snapshot.is_valid?
              dns.snapshot_id = snapshot.id.to_s
              dns.size = snapshot.size.to_s if dns.size.nil?
            else
              @log.fatal snapshot.cstatus
            end
          end
          unless options[:image].nil?
            image = HP::Cloud::Images.new.get(options[:image])
            if image.is_valid?
              dns.imageref = image.id.to_s
            else
              @log.fatal image.cstatus
            end
          end
          dns.size = 1 if dns.size.nil?
          dns.description = options[:description]
          if dns.save == true
            @log.display "Created dns '#{name}' with id '#{dns.id}'."
          else
            @log.fatal dns.cstatus
          end
        }
      end
    end
  end
end
