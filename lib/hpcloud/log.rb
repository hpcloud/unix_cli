module HP
  module Cloud
    class Log
      ERROR_TYPES = { :success              => 0,
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
        @error_status = nil
        @silence_display = nil
      end

      def get_exit_code(exit_status)
        if exit_status.is_a?(Symbol)
          exit_code = ERROR_TYPES[exit_status]
        else
          exit_code = ERROR_TYPES[:unknown_status]
        end
        exit_code = ERROR_TYPES[:unknown_status] if exit_code.nil?
        return exit_code
      end

      def fatal(message, exit_status)
        $stderr.puts message
        exit Log.get_exit_code(exit_status)
      end

      def error(message, exit_status)
        $stderr.puts message
        @exit_status = exit_status
      end

      def display(message)
        say message unless @silence_display
      end
    end
  end
end
