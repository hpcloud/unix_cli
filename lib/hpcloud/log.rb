module HP
  module Cloud
    class Log
      def initialize(shell)
        @silence_display = nil
        @shell = shell
      end

      def fatal(err, exit_status = :general_error)
        error(err, exit_status)
        exit @shell.exit_status.get
      end

      def error(err, exit_status = :general_error)
        if err.kind_of?(String)
          message = err
        else
          if err.kind_of?(CliStatus)
            exit_status = err.error_code
            message = err.to_s
          else
            message = ErrorResponse.new(err).to_s
          end
        end
        $stderr.puts message
        @shell.exit_status.set(exit_status)
      end

      def display(message)
        @shell.say message unless @silence_display
      end
    end
  end
end
