module HP
  module Cloud
    class CLI < Thor
      desc 'servers:ratelimits', "List compute rate limits."
      long_desc <<-DESC
  Lists all the compute rate limits for this project.

Examples:
  hpcloud servers:ratelimits          # List all rate limits
      DESC
      CLI.add_common_options
      define_method "servers:ratelimits" do
        cli_command(options) {
          rsp = Connection.instance.compute.request(            
            :expects => 200,
            :method  => 'GET',
            :path    => 'limits'
          )
          hsh = { "limits" => rsp.body['limits']['rate'] }
          @log.display hsh.to_yaml
        }
      end
    end
  end
end
