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

      def remove(account = nil)
        if account.nil?
          begin
            dir = Dir.new(get_file_name("."))
            dir.entries.each { |x|
              file_name = get_file_name(x)
              begin
                unless (x == "." || x == "..")
                  File.delete(file_name)
                end
              rescue
                warn "Error deleting cache file: #{file_name}"
              end
            }
          rescue
          end
        else
          file_name = get_file_name(account)
          begin
            File.delete(file_name)
          rescue
            return false
          end
        end
        return true
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
        return @aucas[account]
      end

      def write(account, creds)
        @aucas[account] = creds;
        config = @aucas[account]
        if config.nil?
          remove(account)
          return
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

      def default_zone(account, service)
        creds = read(account)
        return nil if creds.nil?
        catalog = creds[:service_catalog]
        return nil if catalog.nil?
        return nil if catalog[service.to_sym].nil?
        return catalog[service.to_sym].keys.sort.first.to_s
      end
    end
  end
end
