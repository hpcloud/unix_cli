require 'thor'
require 'thor/group'
require 'hpcloud/thor_ext/thor'

module HP
  module Cloud
    class CLI < Thor
    
      ERROR_TYPES = { :success              => 0,
                      :general_error        => 1,
                      :not_supported        => 3,
                      :not_found            => 4,
                      :conflicted           => 5,
                      :incorrect_usage      => 64,
                      :permission_denied    => 77,
                      :rate_limited         => 88
                    }

      GOPTS = {:availability_zone => {:type => :string, :aliases => '-z',
                                      :desc => 'Set the availability zone.'},
               :account_name => {:type => :string, :aliases => '-a',
                                 :desc => 'Select account.'}}

      def initialize(*args)
        super
        @log = HP::Cloud::Log.new
      end

      private
      def self.add_common_options
        GOPTS.each { |k,v| method_option(k, v) }
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

      # name of the running CLI script
      def selfname
        ENV['HPCLOUD_CLI_NAME'] || 'hpcloud'
      end

      ### Thor extensions
    
      def ask_with_default(statement, default, color = nil)
        response = ask("#{statement} [#{default}]")
        return response.empty? ? default : response
      end
    
      def error(message, exit_status=nil)
        error_message(message, exit_status)
        exit @exit_status || 1
      end

      def error_message(message, exit_status=nil)
        $stderr.puts message
        if exit_status.is_a?(Symbol)
          @exit_status = ERROR_TYPES[exit_status]
        else
          @exit_status = ERROR_TYPES[:general_error]
        end
      end

      def cli_command(options)
        @exit_status = ERROR_TYPES[:success]
        Connection.instance.set_options(options)
        begin
          yield
        rescue Excon::Errors::BadRequest => error
          display_error_message(error, :incorrect_usage)
        rescue Excon::Errors::InternalServerError => error
          display_error_message(error, :general_error)
        rescue Fog::HP::Errors::ServiceError => error
          display_error_message(error, :general_error)
        rescue Fog::BlockStorage::HP::NotFound => error
          display_error_message(error, :not_found)
        rescue Fog::CDN::HP::NotFound => error
          display_error_message(error, :not_found)
        rescue Fog::Compute::HP::NotFound => error
          display_error_message(error, :not_found)
        rescue Fog::Storage::HP::NotFound => error
          display_error_message(error, :not_found)
        rescue Fog::BlockStorage::HP::Error => error
          display_error_message(error, :general_error)
        rescue Fog::CDN::HP::Error => error
          display_error_message(error, :general_error)
        rescue Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Fog::Storage::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::Conflict => error
          display_error_message(error, :conflicted)
        rescue Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        rescue Excon::Errors::RequestEntityTooLarge => error
          display_error_message(error, :rate_limited)
        rescue SystemExit => error
        rescue Exception => error
          display_error_message(error, :general_error)
        end
        checker = Checker.new
        if checker.process
          warn "A new version v#{checker.latest} of the Unix CLI is available at https://docs.hpcloud.com/cli/unix/install"
        end
        @exit_status = ERROR_TYPES[:success] if @exit_status.nil?
        exit @exit_status
      end
    end
  end
end
