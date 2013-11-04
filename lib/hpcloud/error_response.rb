# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
        ret = ''
        code = nil
        message = nil
        details = nil
        if (response.respond_to?(:status))
          code = response.status.to_s
        end
        if (response.respond_to?(:body))
          details = response.body.to_s
          begin
            err_msg = MultiJson.decode(response.body)
            err_msg.map { |_,v|
              if ! v.kind_of? Hash
                message = v.to_s
                next
              end
              code = v["code"].to_s if v.has_key?("code")
              message = v["message"] if v.has_key?("message")
              details = nil
              details = v["details"] if v.has_key?("details")
            }
          rescue MultiJson::DecodeError => error
          end
        else
          message = "Unknown error response: " + response.to_s
        end
        ret += code + " " unless code.nil?
        ret += message unless message.nil?
        unless details.nil?
          ret += ": " unless ret.empty?
          ret += details
        end
        return ret
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
