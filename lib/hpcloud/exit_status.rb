module HP
  module Cloud
    class ExitStatus
      TYPES = { :success              => 0,
                :general_error        => 1,
                :not_supported        => 3,
                :not_found            => 4,
                :conflicted           => 5,
                :incorrect_usage      => 64,
                :permission_denied    => 77,
                :rate_limited         => 88,
                :unknown_status       => 99
              }

      def initialize
        @exit_status = :success
        @exit_code = 0
      end

      def set(exit_status)
        unless exit_status.is_a?(Symbol)
          warn "Unknown exit status: #{exit_status.to_s}"
          exit_status = :unknown_status
        end
        exit_code = TYPES[exit_status]
        if exit_code.nil?
          warn "Unknown exit status: #{exit_status.to_s}"
          exit_code = TYPES[:unknown_status]
        end
        if exit_code > @exit_code
          @exit_status = exit_status
          @exit_code = exit_code 
        end
      end

      def get
        return @exit_code
      end
    end
  end
end
