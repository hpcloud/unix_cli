require 'hpcloud/commands/config/set'

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
        # ruby 1.8.7 does not like size of an element in an array whose key is a symbol
        # so convert all keys into strings
        settings = Config.new.settings.inject({}){|memo, (k,v)| memo[k.to_s] = v; memo}
        print_table(settings.to_a)
      end

    end
  end
end
