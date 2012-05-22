require 'thor'
require 'thor/group'
require 'hpcloud/thor_ext/thor'

module HP
  module Cloud
    class CLI < Thor
    
      ERROR_TYPES = { :success              => 0,
                      :general_error        => 1,
                      :not_supported        => 3,
                      :not_found            => 4,
                      :incorrect_usage      => 64,
                      :permission_denied    => 77
                    }

      VALID_SERVICE_NAMES = ['storage','compute','cdn']

      # define global options for the CLI
      class_option :availability_zone, :type => :string, :aliases => '-z',
                   :desc => 'The availability zone for the service.'

      private
      def connection(service = :storage, options = {})
        begin
        if service == :storage
          storage_connection(options)
        elsif service == :compute
          compute_connection(options)
        elsif service == :cdn
          cdn_connection(options)
        end
        rescue Exception => e
          error "Please check your HP Cloud Services account to make sure the '#{service.to_s.capitalize!}' service is activated for the appropriate availability zone.\n Exception: #{e}"
        end
      end

      def storage_connection(options = {})
        return @storage_connection if @storage_connection
        storage_credentials = Config.current_credentials
        if storage_credentials
          @storage_connection ||= connection_with(:storage, storage_credentials, options)
        else
          error "Error in connecting to the Storage service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def compute_connection(options = {})
        return @compute_connection if @compute_connection
        compute_credentials = Config.current_credentials
        if compute_credentials
          @compute_connection ||= connection_with(:compute, compute_credentials, options)
        else
          error "Error in connecting to the Compute service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def cdn_connection(options = {})
        return @cdn_connection if @cdn_connection
        cdn_credentials = Config.current_credentials
        if cdn_credentials
          @cdn_connection ||= connection_with(:cdn, cdn_credentials, options)
        else
          error "Error in connecting to the CDN service. Please check your HP Cloud Services account to make sure the account credentials are correct."
        end
      end

      def connection_with(service, service_credentials, options={})
        connection_options = {:connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
                              :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
                              :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
                              :ssl_verify_peer => Config.settings[:ssl_verify]      || false,
                              :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
                              :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil}
        if service == :storage
          Fog::Storage.new( :provider        => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:storage_availability_zone])
        elsif service == :compute
          Fog::Compute.new( :provider        => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:compute_availability_zone])
        elsif service == :cdn
          Fog::CDN.new( :provider            => 'HP',
                            :connection_options => connection_options,
                            :hp_account_id   => service_credentials[:account_id],
                            :hp_secret_key   => service_credentials[:secret_key],
                            :hp_auth_uri     => service_credentials[:auth_uri],
                            :hp_tenant_id    => service_credentials[:tenant_id],
                            :hp_avl_zone     => options[:availability_zone] || Config.settings[:cdn_availability_zone])
        end
      end

      def validate_account(account_credentials)
        connection_options = {:connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
                              :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
                              :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
                              :ssl_verify_peer => Config.settings[:ssl_verify]      || false,
                              :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
                              :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil}
        options = {
            :hp_account_id   => account_credentials[:account_id],
            :hp_secret_key   => account_credentials[:secret_key],
            :hp_auth_uri     => account_credentials[:auth_uri],
            :hp_tenant_id    => account_credentials[:tenant_id]
        }
        # authenticate with Identity service
        Fog::HP.authenticate_v2(options, connection_options)
      end

      # print some non-error output to the user
      def display(message)
        say message unless @silence_display
      end
    
      # use as a block, will silence any output from #display while inside
      def silence_display
        current = @silence_display
        @silence_display = true
        yield
        @silence_display = current # restore previous status
      end
    
      # display error message embedded in a REST response
      def display_error_message(error, exit_status=nil)
        error_message = error.respond_to?(:response) ? parse_error(error.response) : error.message
        if exit_status === false # don't exit
          $stderr.puts error_message
        else
          error error_message, exit_status
        end
      end
    
      # pull the error message out of an XML response
      def parse_error_xml(response)
        response.body =~ /<Message>(.*)<\/Message>/
        return $1 if $1
        response.body
      end

      # pull the error message out of an JSON response
      def parse_error(response)
        begin
          err_msg = MultiJson.decode(response.body)
          # Error message:  {"badRequest": {"message": "Invalid IP protocol ttt.", "code": 400}}
          err_msg.map {|_,v| v["message"] if v.has_key?("message")}
        rescue MultiJson::DecodeError => error
          # Error message: "400 Bad Request\n\nBlah blah"
          response.body    #### the body is not in JSON format so just return it as it is
        end
      end

      # check to see if an error includes a particular text fragment
      def error_message_includes?(error, text)
        error_message = error.respond_to?(:response) ? parse_error(error.response) : error.message
        error_message.include?(text)
      end

      # name of the running CLI script
      def selfname
        ENV['HPCLOUD_CLI_NAME'] || 'hpcloud'
      end
    
      ### Thor extensions
    
      def ask_with_default(statement, default, color = nil)
        response = ask("#{statement} [#{default}]")
        return response.empty? ? default : response
      end
    
      def error(message, exit_status=nil)
        $stderr.puts message
        exit_status = ERROR_TYPES[exit_status] if exit_status.is_a?(Symbol)
        exit exit_status || 1
      end
    
    end
  end
end