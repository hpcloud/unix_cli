module HP
  module Cloud
    class CLI < Thor

      desc 'config:set', "set the value for a setting"
      long_desc <<-DESC
  Set the value for a setting using the options.

Examples:
  hpcloud config:set -z az2

Aliases: loc
      DESC
      method_option :availability_zone, :default => "az1", :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone - az1 or az2.'
      define_method "config:set" do
        begin
          # write the settings to the config file
          unless options.empty?
            Config.update_config(options)
            display "Configuration setting have been saved to the config file."
          end
        rescue Exception => error
          display_error_message(error, :general_error)
        end
      end

    end
  end
end
