require 'yaml'

module HP
  module Cloud
    class Accounts
      attr_reader :directory

      def initialize(dir=nil)
        if dir.nil?
          @directory = ENV['HOME'] + "/.hpcloud/accounts/"
        else
          @directory = dir
        end
        @accts = {}
      end

      def get_file_name(account)
        "#{@directory}#{account.to_s.downcase.gsub(' ', '_')}"
      end

      def get(account = 'default')
        return @accts[account] if @accts[account].nil? == false
        file_name = get_file_name(account)
        if File.exists?(file_name)
          begin
            hsh = YAML::load(File.open(file_name))
            if hsh[:credentials].nil?
              @accts[account] = hsh
            else
              @accts[account] = hsh
              hsh[:credentials].each { |k,v| @accts[account][k] = v }
              @accts[account][:credentials] = nil
            end
          rescue Exception => e
            raise Exception.new('Error reading account file: ' + file_name)
          end
        else
          raise Exception.new('Could not find account file: ' + file_name)
        end
        return @accts[account]
      end

      def set_credentials(account, id, key, uri, tenant)
        @accts[account] = { :account_id => id,
                           :secret_key => key,
                           :auth_uri => uri,
                           :tenant_id => tenant
                         }
      end

#      def connection_options(account = 'default')
#        return {
#          :connect_timeout => Config.settings[:connect_timeout] || Config::CONNECT_TIMEOUT,
#          :read_timeout    => Config.settings[:read_timeout]    || Config::READ_TIMEOUT,
#          :write_timeout   => Config.settings[:write_timeout]   || Config::WRITE_TIMEOUT,
#          :ssl_verify_peer => Config.settings[:ssl_verify_peer]      || false,
#          :ssl_ca_path     => Config.settings[:ssl_ca_path]     || nil,
#          :ssl_ca_file     => Config.settings[:ssl_ca_file]     || nil }
#      end
#
      def write(account='default')
        config = @accts[account]
        if config.nil?
          raise Exception.new("Cannot find account information for #{account}")
        end
        file_name = get_file_name(account)
        begin
          File.open(file_name, 'w') do |file|
            file.write config.to_yaml
          end
        rescue Exception => e
          raise Exception.new("Error writing file #{file_name}")
        end
      end

    end
  end
end
