require 'hpcloud/commands/config/add'

module HP
  module Cloud
    class CLI < Thor

      map 'config:list' => 'config'

      desc 'config', "list the current configuration settings"
      long_desc <<-DESC
  List the current configuration settings.

Examples:
  hpcloud config

Aliases: config:list
      DESC
      def config
        cli_command(options) {
          display Config.new.list
        }
      end
    end
  end
end
