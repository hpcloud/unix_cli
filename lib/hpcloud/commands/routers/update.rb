module HP
  module Cloud
    class CLI < Thor

      desc "routers:update <name>", "Update the specified router."
      long_desc <<-DESC
  Update an existing router with new administrative state or gateway infomration.  If you do not want an external network, use the gateway option with an empty string.

Examples:
  hpcloud routers:update trout -u # Update router 'trout' administrative state:
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Network to use as external router.'
      method_option :adminstateup,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:update" do |name|
        cli_command(options) {
          router = Routers.new.get(name)
          unless options[:adminstateup].nil?
            if options[:adminstateup] == true
              router.admin_state_up = true
            else
              router.admin_state_up = "false"
            end
          end
          unless options[:gateway].nil?
            router.external_gateway_info = Routers.parse_gateway(options[:gateway])
          end
          router.save
          @log.display "Updated router '#{name}'."
        }
      end
    end
  end
end
