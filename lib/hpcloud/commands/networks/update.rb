module HP
  module Cloud
    class CLI < Thor

      desc "networks:update <name>", "Update a network."
      long_desc <<-DESC
  Update network in your account with the specified name.  Optionally, you can specify administrative state, or shared.

Examples:
  hpcloud networks:update netty -u -h  # Updated 'netty' to up and shared:
  hpcloud networks:update netty --no-adminstateup  # Update 'netty' admin state down:
      DESC
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state up.'
      method_option :shared, :default => false,
                    :type => :boolean, :aliases => '-h',
                    :desc => 'Shared.'
      CLI.add_common_options
      define_method "networks:update" do |name|
        cli_command(options) {
          network = Networks.new.get(name)
          if network.is_valid? == false
            @log.fatal "Network with the name '#{name}' does not exist"
          end
          network.shared = options[:shared]
          network.admin_state_up = options[:adminstateup]
          if network.save == true
            @log.display "Updated network '#{name}'"
          else
            @log.fatal network.cstatus
          end
        }
      end
    end
  end
end
