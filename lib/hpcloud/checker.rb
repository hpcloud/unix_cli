# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
