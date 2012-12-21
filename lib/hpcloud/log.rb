module HP
  module Cloud
    class Log
      def initialize(shell)
        @silence_display = nil
        @shell = shell
      end

      def fatal(err, exit_status)
        error(err, exit_status)
        exit @shell.exit_status.get
      end

      def error(err, exit_status)
        if err.kind_of?(String)
          message = err
        else
          message = ErrorResponse.new(err).to_s
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
