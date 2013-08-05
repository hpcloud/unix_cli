module HP
  module Cloud
    class CLI < Thor
      desc 'account:tenants', "List the tenants."
      long_desc <<-DESC
  Lists all the tenants associated with this account.

Examples:
  hpcloud account:tenants          # List all the tenants associated with the account
      DESC
      CLI.add_report_options
      CLI.add_common_options
      define_method "account:tenants" do
        cli_command(options) {
          default_keys = [ "id", "name", "enabled" ]
          ray = Connection.instance.tenants
          Tableizer.new(options, default_keys, ray).print
        }
      end
    end
  end
end
