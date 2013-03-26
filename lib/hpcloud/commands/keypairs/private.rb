require 'hpcloud/commands/keypairs/private/add'
require 'hpcloud/commands/keypairs/private/location'
require 'hpcloud/commands/keypairs/private/remove'

module HP
  module Cloud
    class CLI < Thor

      desc "keypairs:private", "List private keypairs in local directory"
      long_desc <<-DESC
  List the private keys stored on this machine.  These private keys are *not* available on other systems unless you copy them to that system.

Examples:
  hpcloud keypairs:private         # Create the key 'mykey':
  hpcloud keypairs:private mykey   # Create the key 'mykey':
      DESC
      define_method "keypairs:private" do
        cli_command(options) {
          KeypairHelper.private_list.each{ |private_key|
            @log.display private_key
          }
        }
      end
    end
  end
end
