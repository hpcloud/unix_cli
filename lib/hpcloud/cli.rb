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

      private
      def connection(service = :storage, options = {})
        begin
        if service == :storage
          HP::Cloud::Connection.instance.storage(options)
        elsif service == :compute
          HP::Cloud::Connection.instance.compute(options)
        elsif service == :cdn
          HP::Cloud::Connection.instance.cdn(options)
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
