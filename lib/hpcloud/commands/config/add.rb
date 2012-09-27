module HP
  module Cloud
    class CLI < Thor

      map %w(config:set config:update) => 'config:add'

      desc 'config:add key=value [key=value ...]', "set the value for a configuration value"
      long_desc <<-DESC
  Set values in the configuration file.  You may specify multiple name value pairs separated by spaces on a single command line.  Valid settings include:
#{Config.get_known}

Examples:
  hpcloud config:set compute_availability_zone=az-2.region-a.geo-1     # Sets the default availability zone for the compute service.
  hpcloud config:set block_availability_zone=az-2.region-a.geo-1 ssl_verify_peer=false read_time=60    # Sets multiple values

Alias: config:add, config:update
      DESC
      define_method "config:add" do |pair, *pairs|
        cli_command(options) {
          config = Config.new(true)
          updated = ""
          pairs = [pair] + pairs
          pairs.each { |nvp|
            begin
              k, v = Config.split(nvp)
              config.set(k, v)
              updated += " " if updated.empty? == false
              updated += nvp
            rescue Exception => e
              error_message(e.to_s, :general_error)
            end
          }
          if updated.empty? == false
            config.write()
            display "Configuration set " + updated
          end
        }
      end
    end
  end
end
