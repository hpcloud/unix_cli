module HP
  module Cloud
    class CLI < Thor

      map %w(config:add config:update) => 'config:set'

      desc 'config:set key=value [key=value ...]', "set the value for a configuration value"
      long_desc <<-DESC
  Set values in the configuration file.  You may specify multiple name value pairs separated by spaces on a single command line.  Valid settings include:

* connect_timeout (in seconds)
* read_timeout (in seconds)
* write_timeout (in seconds)

Examples:
  hpcloud config:set read_timeout=120     # Sets the read timeout to 120 seconds
  hpcloud config:set write_timeout=60 read_time=60    # Sets multiple values

Alias: config:add, config:update
      DESC
      define_method "config:set" do |pair, *pairs|
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
