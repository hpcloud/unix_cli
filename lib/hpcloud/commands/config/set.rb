module HP
  module Cloud
    class CLI < Thor

      map %w(config:add config:update) => 'config:set'

      desc 'config:set', "set the value for a setting"
      long_desc <<-DESC
  Set values in the configuration file.  Valid settings include:
#{Config.get_known}

Examples:
  hpcloud config:set compute_availability_zone=az-2.region-a.geo-1     # Sets the default availability zone for the compute service.

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
