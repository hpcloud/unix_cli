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
    class CliStatus
      attr_accessor :message, :exit_code, :error_code

      TYPES = { :success              => 0,
                :general_error        => 1,
                :not_supported        => 3,
                :not_found            => 4,
                :conflicted           => 5,
                :incorrect_usage      => 64,
                :permission_denied    => 77,
                :rate_limited         => 88,
                :partial_error        => 98,
                :unknown_status       => 99
              }

      def initialize(message = nil, code = :success)
        @message = message
        @error_code = :success
        @exit_code = 0
        set(code)
      end

      def set(code)
        unless code.is_a?(Symbol)
          if code.is_a?(CliStatus)
            @message = code.message
            code = code.error_code
          else
            warn "Incorrect error code: #{code.to_s}"
            code = :unknown_status
          end
        end
        exit_code = TYPES[code]
        if exit_code.nil?
          warn "Unknown error code: #{code.to_s}"
          exit_code = TYPES[:unknown_status]
        end
        if exit_code > @exit_code
          @error_code = code
          @exit_code = exit_code 
        end
      end

      def is_success?
        return @error_code == :success
      end

      def get
        return @exit_code
      end

      def to_s
        return @message.to_s
      end
    end
  end
end
