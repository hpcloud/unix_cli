module HP
  module Cloud
    class CLI < Thor

      desc "routers:add <name>", "Add a router."
      long_desc <<-DESC
  Add a new router to your network with the specified name.  If a gateway is not specified, the first network that has router_external set to true is used (typically 'Ext-Net'.

Examples:
  hpcloud routers:add routerone   # Create a new router named 'routerone'
  hpcloud routers:add routertwo -g Ext-Net   # Create a new router named 'routertwo' with the specified network as a gateway:
      DESC
      method_option :gateway,
                    :type => :string, :aliases => '-g',
                    :desc => 'Network to use as external router.'
      method_option :adminstateup, :default => true,
                    :type => :boolean, :aliases => '-u',
                    :desc => 'Administrative state.'
      CLI.add_common_options
      define_method "routers:add" do |name|
        cli_command(options) {
          router = Routers.new.unique(name)
          router.name = name
          router.external_gateway_info = parse_gateway(options[:gateway])
          router.admin_state_up = options[:adminstateup]
          router.save
          @log.display "Created router '#{name}' with id '#{router.id}'."
        }
      end

      private

      def parse_gateway(value)
        networks = Networks.new
        unless value.nil?
          return { 'network_id' => networks.get(value).id }
        end
        networks.items.each{ |x|
          if x.router_external == true
            return { 'network_id' => x.id }
          end
        }
        log.fatal "Cannot find external network to use as gateway"
      end

    end
  end
end
