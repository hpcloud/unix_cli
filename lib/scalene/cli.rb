module HP
  module Scalene
    class CLI < Thor
    
      private
    
      def connection
        return @connection if @connection
        credentials = Config.current_credentials
        if credentials
          @connection ||= connection_with(credentials)
        else
          error "Please run `scalene account:setup` to set up your account."
        end
      end
    
      def connection_with(credentials)
        Fog::HP::Storage.new( :hp_access_id =>  credentials[:access_id],
                              :hp_secret_key => credentials[:secret_key],
                              :hp_account_id => credentials[:email],
                              :host => credentials[:host],
                              :port => credentials[:port] )
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
      def parse_error(response)
        response.body =~ /<Message>(.*)<\/Message>/
        return $1 if $1
        response.body
      end
    
      ### Thor extensions
    
      def ask_with_default(statement, default, color = nil)
        response = ask("#{statement} [#{default}]")
        return response.empty? ? default : response
      end
    
      def error(message, exit_status=nil)
        $stderr.puts message
        exit exit_status || 1
      end
    
    end
  end
end