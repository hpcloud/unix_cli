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
    
      private
      def connection(service = :storage)
        if service == :storage
          storage_connection
        elsif service == :compute
          compute_connection
        elsif service == :cdn
          cdn_connection
        end
      end

      def storage_connection
        return @storage_connection if @storage_connection
        storage_credentials = Config.current_credentials
        if storage_credentials
          @storage_connection ||= connection_with(:storage, storage_credentials)
        else
          error "Please check your HP Cloud Services account to make sure the Storage service is activated."
        end
      end

      def compute_connection
        return @compute_connection if @compute_connection
        compute_credentials = Config.current_credentials
        if compute_credentials
          @compute_connection ||= connection_with(:compute, compute_credentials)
        else
          error "Please check your HP Cloud Services account to make sure the Compute service is activated."
        end
      end

      def cdn_connection
        return @cdn_connection if @cdn_connection
        cdn_credentials = Config.current_credentials
        if cdn_credentials
          @cdn_connection ||= connection_with(:cdn, cdn_credentials)
        else
          error "Please check your HP Cloud Services account to make sure the CDN service is activated."
        end
      end

      def connection_with(service, service_credentials)
        connection_options = {:connect_timeout => Config::CONNECT_TIMEOUT || 5,
                            :read_timeout    => Config::READ_TIMEOUT || 5,
                            :write_timeout   => Config::WRITE_TIMEOUT || 5}
        begin
          if service == :storage
            Fog::Storage.new( :provider        => 'HP',
                              :connection_options => connection_options,
                              :hp_account_id   => service_credentials[:account_id],
                              :hp_secret_key   => service_credentials[:secret_key],
                              :hp_auth_uri     => service_credentials[:auth_uri],
                              :hp_tenant_id    => service_credentials[:tenant_id])
          elsif service == :compute
            Fog::Compute.new( :provider        => 'HP',
                              :connection_options => connection_options,
                              :hp_account_id   => service_credentials[:account_id],
                              :hp_secret_key   => service_credentials[:secret_key],
                              :hp_auth_uri     => service_credentials[:auth_uri],
                              :hp_tenant_id    => service_credentials[:tenant_id])
          elsif service == :cdn
            Fog::CDN.new( :provider        => 'HP',
                              :connection_options => connection_options,
                              :hp_account_id   => service_credentials[:account_id],
                              :hp_secret_key   => service_credentials[:secret_key],
                              :hp_auth_uri     => service_credentials[:auth_uri],
                              :hp_tenant_id    => service_credentials[:tenant_id])
          end
        rescue
          error "Error connecting to the service endpoint at: #{service_credentials[:auth_uri]}."
        end
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