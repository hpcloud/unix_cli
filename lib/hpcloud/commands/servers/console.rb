module HP
  module Cloud
    class CLI < Thor

      desc "servers:console <server_name_or_id> [lines]", "Get the console output of a server."
      long_desc <<-DESC
  Dump out the console output of a server.

Examples:
  hpcloud servers:console my-server 100         # Get 100 lines of console ouput
      DESC
      CLI.add_common_options
      define_method "servers:console" do |name_or_id, *lines|
        cli_command(options) {
          lines = ["50"] if lines.nil? || lines.empty?
          lines = lines[0]
          if lines.match(/[^0-9]/)
            error "Invalid number of lines specified '#{lines}'", :incorrect_usage
          end
          lines = lines.to_i + 1
          lines = lines.to_s
          server = Servers.new.get(name_or_id)
          if server.is_valid?
            output = server.fog.console_output(lines)
            if output.nil?
              error "Error getting console response from #{name_or_id}", :general_error
            end
            display "Console output for #{name_or_id}:"
            display output.body
          else
            error server.error_string, server.error_code
          end
        }
      end
    end
  end
end
