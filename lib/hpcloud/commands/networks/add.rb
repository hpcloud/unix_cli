module HP
  module Cloud
    class CLI < Thor

      desc "networks:add <name> [size]", "Add a network."
      long_desc <<-DESC
  Add a new network in your account with the specified name.  Optionally, you can specify subnets, administrative state, or shared.

Examples:
  hpcloud networks:add netty        # Create a new network named 'netty':
  hpcloud networks:add netty -u -h  # Create a new network named 'netty' up and shared:
      DESC
      method_option :subnets,
                    :type => :string, :aliases => '-s',
                    :desc => 'Comma separated list of Subnets to add.'
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state up.'
      method_option :shared, :default => false,
                    :type => :boolean, :aliases => '-h',
                    :desc => 'Shared.'
      CLI.add_common_options
      define_method "networks:add" do |name|
        cli_command(options) {
          if Networks.new.get(name).is_valid? == true
            @log.fatal "Network with the name '#{name}' already exists"
          end
          network = HP::Cloud::NetworkHelper.new(Connection.instance)
          network.name = name
          unless options[:subnets].nil?
            subnets = HP::Cloud::Subnets.new.get(options[:subnets])
            if subnets.is_valid?
              network.subnets = subnets.id.to_s
            else
              @log.fatal subnets.cstatus
            end
          end
          if network.save == true
            @log.display "Created network '#{name}' with id '#{network.id}'."
          else
            @log.fatal network.cstatus
          end
        }
      end
    end
  end
end
