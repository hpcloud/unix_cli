module HP
  module Cloud
    class CLI < Thor

      desc "routers:update <name>", "Update the specified router."
      long_desc <<-DESC
  Update an existing router with new gateway or administrative state information.

Examples:
  hpcloud routers:update subwoofer -g 10.0.0.1 -u # Update 'subwoofer' gateway and administrative state:
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Gateway IP address.'
      method_option :adminstateup,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:update" do |name|
        cli_command(options) {
          router = Routers.new.get(name)
          if router.is_valid? == false
            @log.fatal router.cstatus
          end
          router.set_gateway(options[:gateway]) unless options[:gateway].nil?
          router.admin_state_up = options[:adminstateup] unless options[:adminstateup].nil?
          if router.save == true
            @log.display "Updated router '#{name}'."
          else
            @log.fatal router.cstatus
          end
        }
      end
    end
  end
end
