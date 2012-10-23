module HP
  module Cloud
    class CLI < Thor

      map 'flavors:list' => 'flavors'

      desc "flavors [name_or_id ...]", "List available flavors."
      long_desc <<-DESC
  List the flavors in your compute account. You may filter the output by specifying the names or ids of the flavors you wish to see.  Optionally, an availability zone can be passed.

Examples:
  hpcloud flavors                         # List flavors
  hpcloud flavors xsmall small            # List flavors xsmall and small
  hpcloud flavors -z az-2.region-a.geo-1  # List flavors for an availability zone

Aliases: flavors:list
      DESC
      CLI.add_common_options
      def flavors(*arguments)
        cli_command(options) {
          flavors = Flavors.new
          if flavors.empty?
            display "You currently have no flavors."
          else
            hsh = flavors.get_hash(arguments)
            if hsh.empty?
              display "There are no flavors that match the provided arguments"
            else
              Tableizer.new(options, FlavorHelper.get_keys(), hsh).print
            end
          end
        }
      end
    end
  end
end
