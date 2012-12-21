module HP
  module Cloud
    class ErrorResponse

      attr_reader :error, :error_string
    
      def initialize(error)
        @error = error
        if (error.respond_to?(:response))
          @error_string = parse_error(error.response)
        else
          @error_string = error.message
        end
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

      def to_s
        @error_string
      end
    end
  end
end
