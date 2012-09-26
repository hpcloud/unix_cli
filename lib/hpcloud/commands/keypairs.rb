require 'hpcloud/commands/keypairs/import'
require 'hpcloud/commands/keypairs/add'
require 'hpcloud/commands/keypairs/remove'

module HP
  module Cloud
    class CLI < Thor

      map 'keypairs:list' => 'keypairs'

      desc "keypairs", "list of available keypairs"
      long_desc <<-DESC
  List the keypairs in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud keypairs                           # List keypairs
  hpcloud keypairs -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: keypairs:list
      DESC
      CLI.add_common_options
      def keypairs(*arguments)
        cli_command(options) {
          keypairs = Keypairs.new
          if keypairs.empty?
            display "You currently have no keypairs, use `#{selfname} keypairs:add <name>` to create one."
          else
            hsh = keypairs.get_hash(arguments)
            if hsh.empty?
              display "There are no keypairs that match the provided arguments"
            else
              tablelize(hsh, KeypairHelper.get_keys())
            end
          end
        }
      end
    end
  end
end
