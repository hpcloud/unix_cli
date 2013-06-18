module HP
  module Cloud
    class CLI < Thor

      desc "networks:update <name>", "Update a network."
      long_desc <<-DESC
  Update network in your account with the specified name.  The administrative state may be updated.

Examples:
  hpcloud networks:update netty -u # Updated 'netty' to up
  hpcloud networks:update netty --no-adminstateup  # Update 'netty' admin state down
      DESC
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state up.'
      CLI.add_common_options
      define_method "networks:update" do |name|
        cli_command(options) {
          network = Networks.new.get(name)
          if network.is_valid? == false
            @log.fatal "Network with the name '#{name}' does not exist"
          end
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
