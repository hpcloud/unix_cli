require 'hpcloud/commands/cdn_containers/add'
require 'hpcloud/commands/cdn_containers/remove'
#require 'hpcloud/commands/cdn_containers/set'
#require 'hpcloud/commands/cdn_containers/location'

module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:list' => 'cdn:containers'

      desc "cdn:containers", "list of available containers on the CDN"
      long_desc <<-DESC
  List the available containers on the Content Delivery Network (CDN).

Examples:
  hpcloud cdn:containers         # list only the CDN-enabled containers
  hpcloud cdn:containers -a      # list all the container on the CDN

Aliases: cdn:containers:list
      DESC
      method_option :all, :default => false, :type => :boolean, :aliases => '-a',
                    :desc => 'List all the CDN containers, either enabled or disabled.'
      define_method "cdn:containers" do
        begin
          response = if options[:all]
            connection(:cdn).get_containers()
          else
            connection(:cdn).get_containers({'enabled_only' => true})
          end
          cdn_containers = response.body
          if cdn_containers.nil? or cdn_containers.empty?
            display "You currently have no containers on the CDN."
          else
            cdn_containers.each { |cdn_container| display cdn_container['name'] }
          end
        rescue Fog::CDN::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end