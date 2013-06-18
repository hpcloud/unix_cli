module HP
  module Cloud
    class CLI < Thor

      desc "networks:add <name>", "Add a network."
      long_desc <<-DESC
  Add a new network in your account with the specified name.  Optionally, you can specify administrative state.

Examples:
  hpcloud networks:add netty        # Create a new network named 'netty'
  hpcloud networks:add netty --no-adminstateup  # Create a new network named 'netty' admin state down
      DESC
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state up.'
      CLI.add_common_options
      define_method "networks:add" do |name|
        cli_command(options) {
          if Networks.new.get(name).is_valid? == true
            @log.fatal "Network with the name '#{name}' already exists"
          end
          network = HP::Cloud::NetworkHelper.new(Connection.instance)
          network.name = name
          network.admin_state_up = options[:adminstateup]
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
