module HP
  module Cloud
    class CLI < Thor

      map %w(config:add config:update) => 'config:set'

      desc 'config:set key=value [key=value ...]', "Set values in the configuration file."
      long_desc <<-DESC
  Set values in the configuration file.  You may specify multiple name value pairs separated by spaces on a single command line.  Valid settings include:

* connect_timeout (in seconds)
* read_timeout (in seconds)
* write_timeout (in seconds)

Examples:
  hpcloud config:set read_timeout=120     # Set the read timeout to 120 seconds:
  hpcloud config:set write_timeout=60 read_time=60    # Set the write timeout to 60 seconds and the read timeout to 60 seconds:

Aliases: config:add, config:update
      DESC
      define_method "config:set" do |pair, *pairs|
        cli_command(options) {
          config = Config.new(true)
          updated = ""
          pairs = [pair] + pairs
          pairs.each { |nvp|
            sub_command {
              k, v = Config.split(nvp)
              config.set(k, v)
              updated += " " if updated.empty? == false
              updated += nvp
            }
          }
          if updated.empty? == false
            config.write()
            @log.display "Configuration set " + updated
          end
        }
      end
    end
  end
end
