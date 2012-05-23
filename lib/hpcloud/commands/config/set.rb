module HP
  module Cloud
    class CLI < Thor

      desc 'config:set', "set the value for a setting"
      long_desc <<-DESC
  Set the value for a setting in the configuration file for a given service.

Examples:
  hpcloud config:set -s compute -z az-2.region-a.geo-1     # Sets the availability zone for the compute service

      DESC
      method_option :service_name, :type => :string,
                    :aliases => '-s', :required => :true,
                    :desc => 'Specify the name of the service, for which the configuration setting is intended.'
      define_method "config:set" do
        # Refactor for common settings later
        service_name = options[:service_name]
        if VALID_SERVICE_NAMES.include? (service_name)
          # write the settings to the config file
          settings = manage_settings(service_name, options)
          unless settings.empty?
            Config.update_config(settings)
            display "The configuration setting(s) have been saved to the config file."
          else
            display "No configuration setting(s) were saved."
          end
        else
          error("The service name is not valid. The service name has to be one of these: #{VALID_SERVICE_NAMES.join(', ')}", :not_supported)
        end
      end

      private

      def manage_settings(service_name, options)
        settings = {}
        unless options.empty?
          settings["#{service_name}_availability_zone"] = options[:availability_zone] unless options[:availability_zone].nil?
        end
        settings
      end

    end
  end
end
