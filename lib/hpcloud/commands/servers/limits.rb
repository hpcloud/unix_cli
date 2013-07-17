module HP
  module Cloud
    class CLI < Thor
      desc 'servers:limits', "List compute limits."
      long_desc <<-DESC
  Lists all the compute limits for this project.

Examples:
  hpcloud servers:limits          # List all limits
      DESC
      CLI.add_common_options
      define_method "servers:limits" do
        cli_command(options) {
          rsp = Connection.instance.compute.request(            
            :expects => 200,
            :method  => 'GET',
            :path    => 'limits'
          )
          hsh = { "limits" => rsp.body['limits']['absolute'] }
          @log.display hsh.to_yaml
        }
      end
    end
  end
end
