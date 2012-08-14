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
                      :permission_denied    => 77,
                      :rate_limited         => 88
                    }

      VALID_SERVICE_NAMES = ['storage','compute','cdn']

      private
      def connection(service = :storage, options = {})
        begin
        Connection.instance.set_options(options)
        if service == :storage
          return Connection.instance.storage()
        elsif service == :compute
          return Connection.instance.compute()
        elsif service == :cdn
          return Connection.instance.cdn()
        end
        rescue Exception => e
          raise Fog::HP::Errors::ServiceError, "Please check your HP Cloud Services account to make sure the '#{service.to_s.capitalize!}' service is activated for the appropriate availability zone.\n Exception: #{e}"
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

      def default_connection_options(options={})
        # define default connection options
        {
            :connect_timeout => Config.settings[:connect_timeout] || options[:connect_timeout] || Config::CONNECT_TIMEOUT,
            :read_timeout    => Config.settings[:read_timeout]    || options[:read_timeout] || Config::READ_TIMEOUT,
            :write_timeout   => Config.settings[:write_timeout]   || options[:write_timeout] || Config::WRITE_TIMEOUT,
            :ssl_verify_peer => Config.settings[:ssl_verify_peer] || options[:ssl_verify_peer] || false,
            :ssl_ca_path     => Config.settings[:ssl_ca_path]     || options[:ssl_ca_path],
            :ssl_ca_file     => Config.settings[:ssl_ca_file]     || options[:ssl_ca_file]
        }
      end

      def tablelize(data, attributes=nil)
        return if data.nil?
        Formatador.display_table(data, attributes)
      end

      ### Thor extensions
    
      def ask_with_default(statement, default, color = nil)
        response = ask("#{statement} [#{default}]")
        return response.empty? ? default : response
      end
    
      def error_message(message, exit_status=nil)
        $stderr.puts message
        if exit_status.is_a?(Symbol)
          @exit_status = ERROR_TYPES[exit_status]
        else
          @exit_status = ERROR_TYPES[:general_error]
        end
      end

      def error(message, exit_status=nil)
        error_message(message, exit_status)
        exit @exit_status || 1
      end

      def cli_command(options)
        Connection.instance.set_options(options)
        begin
          yield
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        end
      end

    end
  end
end
