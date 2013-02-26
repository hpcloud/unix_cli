module HP
  module Cloud
    class CLI < Thor

      map 'flavors:list' => 'flavors'

      desc "flavors [name_or_id ...]", "List available flavors."
      long_desc <<-DESC
  List the flavors in your compute account. You may filter the output by specifying the names or IDs of the flavors you wish to see.  Optionally, you can specify an availability zone.

Examples:
  hpcloud flavors                         # List the flavors:
  hpcloud flavors xsmall small            # List the flavors `xsmall` and `small`:
  hpcloud flavors -z az-2.region-a.geo-1  # List the flavors for  availability zone `az-2.region-a.geo-1`:

Aliases: flavors:list
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def flavors(*arguments)
        cli_command(options) {
          flavors = Flavors.new
          if flavors.empty?
            @log.display "You currently have no flavors."
          else
            ray = flavors.get_array(arguments)
            if ray.empty?
              @log.display "There are no flavors that match the provided arguments"
            else
              Tableizer.new(options, FlavorHelper.get_keys(), ray).print
            end
          end
        }
      end
    end
  end
end
