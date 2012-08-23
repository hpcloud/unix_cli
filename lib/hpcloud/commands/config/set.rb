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
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "config:set" do
        # Refactor for common settings later
        service_name = options[:service_name]
        if HP::Cloud::Connection.is_service(service_name)
          begin
            config = Config.new(true)
            key = "#{service_name}_availability_zone"
            value = options[:availability_zone]
            config.set(key, value)
            config.write()
            display "The configuration setting(s) have been saved to the config file."
          rescue
            display "No configuration setting(s) were saved."
          end
        else
          error("The service name is not valid. The service name has to be one of these: #{HP::Cloud::Connection.get_services()}", :not_supported)
        end
      end
    end
  end
end
