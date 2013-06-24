module HP
  module Cloud
    class CLI < Thor

      map %w(subnets:rm subnets:delete subnets:del) => 'subnets:remove'

      desc "subnets:remove name_or_id [name_or_id ...]", "Remove a subnet (specified by name or ID)."
      long_desc <<-DESC
  Remove subnet by specifying their names or ID. You may specify more than one subnet name or ID on a command line.

Examples:
  hpcloud subnets:remove blue red   # Delete the subnet 'blue' and 'red'
  hpcloud subnets:remove 998          # Delete the subnet with ID 998
  hpcloud subnets:remove netty -z region-a.geo-1  # Delete the subnet `netty` for availability zone `region-a.geo-1`

Aliases: subnets:rm, subnets:delete, subnets:del
      DESC
      CLI.add_common_options
      define_method "subnets:remove" do |name_or_id, *name_or_ids|
        cli_command(options) {
          name_or_ids = [name_or_id] + name_or_ids
          subnets = Subnets.new.get(name_or_ids, false)
          subnets.each { |subnet|
            sub_command("removing subnet") {
              if subnet.is_valid?
                subnet.destroy
                @log.display "Removed subnet '#{subnet.name}'."
              else
                @log.error subnet.cstatus
              end
            }
          }
        }
      end
    end
  end
end
