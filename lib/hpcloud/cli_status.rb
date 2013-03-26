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
