require 'open-uri'

module HP
  module Cloud
    class Checker
      attr_accessor :url, :deferment, :file, :latest

      @@home = nil

      def initialize
        if @@home.nil?
          @@home = ENV['HOME']
        end
        @directory = @@home + "/.hpcloud/"
        @file = @directory + ".checker"
        config = Config.new
        @url = config.get(:checker_url)
        @deferment = config.get(:checker_deferment)
      end

      def self.home_directory=(dir)
        @@home = dir
      end

      def self.split(value)
        value = value.strip.split('.')
        major = value[0] if value.length > 0
        minor = value[1] if value.length > 1
        build = value[2] if value.length > 2
        return major, minor, build
      end

      def comparo(latest)
        lmajor, lminor, lbuild = Checker.split(latest)
        major, minor, build = Checker.split(HP::Cloud::VERSION)
        lmajor = lmajor.to_i
        lminor = lminor.to_i
        lbuild = lbuild.to_i
        major = major.to_i
        minor = minor.to_i
        build = build.to_i
        return true if lmajor > major
        return false if lmajor < major
        return true if lminor > minor
        return false if lminor < minor
        return true if lbuild > build
        return false
      end

      def process
        return false if @deferment == 0
        return false if @url.nil?
        if File.exists?(@file)
          begin
            mtime = File.new(@file).mtime
            now = Time.now
          rescue
            return false
          end
          return false if ((now - mtime) < @deferment)
        end

        begin
          FileUtils.mkdir_p(@directory)
          FileUtils.touch(@file)
        rescue
        end

        begin
          @latest = open(@url).read.strip
          return false unless comparo(@latest)
        rescue
          return false
        end
        return true
      end

      def reset
        FileUtils.rm_rf(@file)
      end
    end
  end
end
