require 'yaml'

module HP
  module Cloud
    class Accounts
      attr_reader :directory
      @@home = nil

      def initialize
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/accounts/"
        @accts = {}
      end

      def self.home_directory=(dir)
        @@home = dir
      end

      def get_file_name(account)
        "#{@directory}#{account.to_s.downcase.gsub(' ', '_')}"
      end

      def read(account = 'default')
        return @accts[account] if @accts[account].nil? == false
        file_name = get_file_name(account)
        if File.exists?(file_name)
          begin
            hsh = YAML::load(File.open(file_name))
            hsh[:credentials] = {} if hsh[:credentials].nil?
            hsh[:zones] = {} if hsh[:zones].nil?
            hsh[:options] = {} if hsh[:options].nil?
            @accts[account] = hsh
          rescue Exception => e
            raise Exception.new('Error reading account file: ' + file_name)
          end
        else
          raise Exception.new('Could not find account file: ' + file_name)
        end
        return @accts[account]
      end

      def set_credentials(account, id, key, uri, tenant)
        if @accts[account].nil?
          @accts[account] = {:credentials=>{}, :zones=>{}, :options=>{}}
        end
        @accts[account][:credentials] = { :account_id => id,
                                          :secret_key => key,
                                          :auth_uri => uri,
                                          :tenant_id => tenant
                                        }
      end

      #def set(account, values)
      #  @accts[account] = values
      #end

      def set_zones(account, compute, storage, cdn, block)
        hsh = @accts[account]
        hsh[:zones][:compute_availability_zone] = compute
        hsh[:zones][:storage_availability_zone] = storage
        hsh[:zones][:cdn_availability_zone] = cdn
        hsh[:zones][:block_availability_zone] = block
      end

      def get(account = 'default')
        hsh = read(account).clone
        settings = Config.new.settings
        hsh[:zones][:compute_availability_zone] ||= settings[:compute_availability_zone]
        hsh[:zones][:storage_availability_zone] ||= settings[:storage_availability_zone]
        hsh[:zones][:cdn_availability_zone] ||= settings[:cdn_availability_zone]
        hsh[:zones][:block_availability_zone] ||= settings[:block_availability_zone]
        hsh[:options][:connect_timeout] ||= settings[:connect_timeout]
        hsh[:options][:read_timeout] ||= settings[:read_timeout]
        hsh[:options][:write_timeout] ||= settings[:write_timeout]
        hsh[:options][:ssl_verify_peer] ||= settings[:ssl_verify_peer]
        hsh[:options][:ssl_ca_path] ||= settings[:ssl_ca_path]
        hsh[:options][:ssl_ca_file] ||= settings[:ssl_ca_file]
        return hsh
      end

      def write(account='default')
        config = @accts[account]
        if config.nil?
          raise Exception.new("Cannot find account information for #{account}")
        end
        file_name = get_file_name(account)
        begin
          FileUtils.mkpath(@directory)
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
