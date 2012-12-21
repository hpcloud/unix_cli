require 'thor'
require 'thor/group'
require 'hpcloud/thor_ext/thor'

module HP
  module Cloud
    class CLI < Thor
      attr_accessor :exit_status
    
      GOPTS = {:availability_zone => {:type => :string, :aliases => '-z',
                                      :desc => 'Set the availability zone.'},
               :account_name => {:type => :string, :aliases => '-a',
                                 :desc => 'Select account.'}}

      def initialize(*args)
        super
        @exit_status = HP::Cloud::ExitStatus.new
        @log = HP::Cloud::Log.new(self)
      end

      private
      def self.add_common_options
        GOPTS.each { |k,v| method_option(k, v) }
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
    
      def cli_command(options)
        Connection.instance.set_options(options)
        begin
          yield
        rescue Excon::Errors::BadRequest => error
          @log.fatal(error, :incorrect_usage)
        rescue Excon::Errors::InternalServerError => error
          @log.fatal(error, :general_error)
        rescue Fog::HP::Errors::ServiceError => error
          @log.fatal(error, :general_error)
        rescue Fog::BlockStorage::HP::NotFound => error
          @log.fatal(error, :not_found)
        rescue Fog::CDN::HP::NotFound => error
          @log.fatal(error, :not_found)
        rescue Fog::Compute::HP::NotFound => error
          @log.fatal(error, :not_found)
        rescue Fog::Storage::HP::NotFound => error
          @log.fatal(error, :not_found)
        rescue Fog::BlockStorage::HP::Error => error
          @log.fatal(error, :general_error)
        rescue Fog::CDN::HP::Error => error
          @log.fatal(error, :general_error)
        rescue Fog::Compute::HP::Error => error
          @log.fatal(error, :general_error)
        rescue Fog::Storage::HP::Error => error
          @log.fatal(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          @log.fatal(error, :permission_denied)
        rescue Excon::Errors::Conflict => error
          @log.fatal(error, :conflicted)
        rescue Excon::Errors::NotFound => error
          @log.fatal(error, :not_found)
        rescue Excon::Errors::RequestEntityTooLarge => error
          @log.fatal(error, :rate_limited)
        rescue SystemExit => error
        rescue Exception => error
          @log.fatal(error, :general_error)
        end
        checker = Checker.new
        if checker.process
          warn "A new version v#{checker.latest} of the Unix CLI is available at https://docs.hpcloud.com/cli/unix/install"
        end
        exit @exit_status.get
      end
    end
  end
end
