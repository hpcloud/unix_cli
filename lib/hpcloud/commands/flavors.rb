module HP
  module Cloud
    class CLI < Thor

      map 'flavors:list' => 'flavors'

      desc "flavors", "list of available flavors"
      long_desc <<-DESC
  List the flavors in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud flavors                         # List flavors
  hpcloud flavors -z az-2.region-a.geo-1  # List flavors for an availability zone

Aliases: flavors:list
      DESC
      CLI.add_common_options
      def flavors
        cli_command(options) {
          flavors = connection(:compute, options).flavors
          if flavors.empty?
            display "You currently have no flavors."
          else
            # :rxtx_cap, :rxtx_quota, :swap, :vcpus are not attributes on model
            flavors.table([:id, :name, :ram, :disk])
          end
        }
      end
    end
  end
end
