module HP
  module Cloud
    class ErrorResponse

      attr_reader :error, :error_string
    
      def initialize(error)
        @error = error
        if (error.respond_to?(:response))
          @error_string = parse_error(error.response)
        else
          begin
            @error_string = error.message
          rescue
            @error_string = error.to_s
          end
        end
      end

      # pull the error message out of an JSON response
      def parse_error(response)
        begin
          if (response.respond_to?(:body))
            err_msg = MultiJson.decode(response.body)
          elese
            err_msg = "Unknown error response: " + response.to_s
          end
          ret = ''
          err_msg.map { |_,v|
            ret += v["code"].to_s + " " if v.has_key?("code")
            ret += v["message"] if v.has_key?("message")
            ret += ": " + v["details"] if v.has_key?("details")
          }
          return ret
        rescue MultiJson::DecodeError => error
          response.body
        end
      end

      # check to see if an error includes a particular text fragment
      def error_message_includes?(error, text)
        error_message = error.respond_to?(:response) ? parse_error(error.response) : error.message
        error_message.include?(text)
      end

      def to_s
        @error_string
      end
    end
  end
end
