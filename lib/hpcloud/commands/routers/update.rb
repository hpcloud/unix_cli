module HP
  module Cloud
    class CLI < Thor

      desc "routers:update <name>", "Update the specified router."
      long_desc <<-DESC
  Update an existing router with new administrative state information.

Examples:
  hpcloud routers:update trout -u # Update router 'trout' administrative state:
      DESC
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
          router.save
          @log.display "Updated router '#{name}'."
        }
      end
    end
  end
end
