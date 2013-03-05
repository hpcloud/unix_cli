require 'thor'
require 'thor/group'
require 'hpcloud/thor_ext/thor'

module HP
  module Cloud
    class CLI < Thor
      attr_accessor :exit_status
    
      GOPTS = {:availability_zone => {:type => :string, :aliases => '-z',
                                      :desc => 'Set the availability zone.'},
               :debug => {:type => :string, :aliases => '-x',
                                 :desc => 'Debug logging 1,2,3,...'},
               :account_name => {:type => :string, :aliases => '-a',
                                 :desc => 'Select account.'}}

      def initialize(*args)
        super
        @@debugging = false
        @@error = nil
        @exit_status = HP::Cloud::CliStatus.new
        @log = HP::Cloud::Log.new(self)
      end

      private
      def self.add_common_options
        GOPTS.each { |k,v| method_option(k, v) }
      end

      def self.add_report_options
        method_option(Columns.option_name, Columns.option_args)
        method_option(Tableizer.option_name, Tableizer.option_args)
      end

      # name of the running CLI script
      def selfname
        ENV['HPCLOUD_CLI_NAME'] || 'hpcloud'
      end

      class << self
        def exit_on_failure?
          true
        end
      end

      ### Thor extensions
    
      def ask_with_default(statement, default, color = nil)
        response = ask("#{statement} [#{default}]")
        return response.empty? ? default : response
      end
    
      def cli_command(options)
        unless options[:debug].nil?
          if options[:debug] > '1'
            ENV['EXCON_STANDARD_INSTRUMENTOR']='1'
          end
          @@debugging = true
        end
        Connection.instance.set_options(options)
        sub_command { yield }
        checker = Checker.new
        if checker.process
          warn "A new version v#{checker.latest} of the Unix CLI is available at https://docs.hpcloud.com/cli/unix/install"
        end
        exit @exit_status.get
      end
    
      def sub_command(action=nil)
        error_status = nil
        begin
          yield
        rescue Excon::Errors::BadRequest => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :incorrect_usage
        rescue Excon::Errors::InternalServerError => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :general_error
        rescue Fog::HP::Errors::ServiceError => error
          @@error = error
          error_status = :general_error
        rescue Fog::HP::BlockStorage::NotFound => error
          @@error = error
          error_status = :not_found
        rescue Fog::CDN::HP::NotFound => error
          @@error = error
          error_status = :not_found
        rescue Fog::Compute::HP::NotFound => error
          @@error = error
          error_status = :not_found
        rescue Fog::Storage::HP::NotFound => error
          @@error = error
          error_status = :not_found
        rescue Fog::HP::BlockStorage::Error => error
          @@error = error
          error_status = :general_error
        rescue Fog::CDN::HP::Error => error
          @@error = error
          error_status = :general_error
        rescue Fog::Compute::HP::Error => error
          @@error = error
          error_status = :general_error
        rescue Fog::Storage::HP::Error => error
          @@error = error
          error_status = :general_error
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :permission_denied
        rescue Excon::Errors::Conflict => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :conflicted
        rescue Excon::Errors::NotFound => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :not_found
        rescue Excon::Errors::RequestEntityTooLarge => error
          @@error = ErrorResponse.new(error).to_s
          error_status = :rate_limited
        rescue SystemExit => error
          @@error = error
        rescue Exception => error
          @@error = error
          error_status = :general_error
        end
        unless error_status.nil?
          if action.nil?
            @log.error(@@error, error_status)
          else
            @@error = "Error #{action}: #{@@error.to_s}"
            @log.error(@@error, error_status)
          end
        end
        if @@debugging == true
          unless @@error.nil?
            if @@error.kind_of?(Exception)
              puts @@error.backtrace
            end
          end
        end
        @exit_status.get
      end
    end
  end
end
