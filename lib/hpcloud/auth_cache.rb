require 'yaml'

module HP
  module Cloud
    class AuthCache
      attr_reader :directory
      @@home = nil

      def initialize
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/accounts/.cache/"
        @aucas = {}
      end

      def self.home_directory=(dir)
        @@home = dir
      end

      def get_file_name(account)
        "#{@directory}#{account.to_s.downcase.gsub(' ', '_')}"
      end

      def remove(account)
        begin
          file_name = get_file_name(account)
          File.delete(file_name)
          return true
        rescue
        end
        return false
      end

      def read(account)
        return @aucas[account] if @aucas[account].nil? == false
        file_name = get_file_name(account)
        if File.exists?(file_name)
          begin
            @aucas[account] = YAML::load(File.open(file_name))
          rescue Exception => e
            raise Exception.new('Error reading cache file: ' + file_name)
          end
        end
        @aucas[account] = {} if @aucas[account].nil?
        return @aucas[account]
      end

      def get_block(account)
        return read(account)[:block]
      end

      def get_cdn(account)
        return read(account)[:cdn]
      end

      def get_compute(account)
        return read(account)[:compute]
      end

      def get_storage(account)
        return read(account)[:storage]
      end

      def set_block(account, creds)
        read(account)[:block] = creds
        write(account)
      end

      def set_cdn(account, creds)
        read(account)[:cdn] = creds
        write(account)
      end

      def set_compute(account, creds)
        read(account)[:compute] = creds
        write(account)
      end

      def set_storage(account, creds)
        read(account)[:storage] = creds
        write(account)
      end

      def write(account)
        config = @aucas[account]
        if config.nil?
          raise Exception.new("Cannot find cache information for #{account}")
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
