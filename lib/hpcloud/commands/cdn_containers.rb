require 'hpcloud/commands/cdn_containers/add'
require 'hpcloud/commands/cdn_containers/remove'
require 'hpcloud/commands/cdn_containers/set'
require 'hpcloud/commands/cdn_containers/get'
require 'hpcloud/commands/cdn_containers/location'

module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:list' => 'cdn:containers'

      desc "cdn:containers", "List available containers on the CDN."
      long_desc <<-DESC
  List the available containers on the Content Delivery Network (CDN). Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers                    # list only the CDN-enabled containers
  hpcloud cdn:containers -l                 # list all the container on the CDN
  hpcloud cdn:containers -z region-a.geo-1  # Optionally specify an availability zone

Aliases: cdn:containers:list
      DESC
      method_option :all, :default => false,
                    :type => :boolean, :aliases => '-l',
                    :desc => 'List all the CDN containers, either enabled or disabled.'
      CLI.add_common_options
      define_method "cdn:containers" do
        cli_command(options) {
          response = if options[:all]
            Connection.instance.cdn.get_containers()
          else
            Connection.instance.cdn.get_containers({'enabled_only' => true})
          end
          cdn_containers = response.body
          if cdn_containers.nil? or cdn_containers.empty?
            display "You currently have no containers on the CDN."
          else
            cdn_containers.each { |cdn_container| display cdn_container['name'] }
          end
        }
      end
    end
  end
end
