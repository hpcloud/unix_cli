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

      def get_name(opts)
        begin
          "#{opts[:hp_access_key]}:#{opts[:hp_tenant_id]}"
        rescue
          "default"
        end
      end

      def get_file_name(opts)
        return "#{@directory}" if opts.nil?
        "#{@directory}#{get_name(opts)}"
      end

      def remove(opts = nil)
        if opts.nil?
          begin
            dirname = get_file_name(nil)
            dir = Dir.new(dirname)
            dir.entries.each { |x|
              file_name = dirname + x
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
          file_name = get_file_name(opts)
          begin
            File.delete(file_name)
          rescue
            return false
          end
        end
        return true
      end

      def read(opts)
        account = get_name(opts)
        return @aucas[account] if @aucas[account].nil? == false
        file_name = get_file_name(opts)
        if File.exists?(file_name)
          begin
            @aucas[account] = YAML::load(File.open(file_name))
          rescue Exception => e
            raise Exception.new('Error reading cache file: ' + file_name)
          end
        end
        return @aucas[account]
      end

      def write(opts, creds)
        account = get_name(opts)
        @aucas[account] = creds;
        config = @aucas[account]
        if config.nil?
          remove(opts)
          return
        end
        file_name = get_file_name(opts)
        begin
          FileUtils.mkpath(@directory)
          File.open(file_name, 'w') do |file|
            file.write config.to_yaml
          end
        rescue Exception => e
          raise Exception.new("Error writing file #{file_name}")
        end
      end

      def default_zone(opts, service)
        creds = read(opts)
        return nil if creds.nil?
        catalog = creds[:service_catalog]
        return nil if catalog.nil?
        return nil if catalog[service.to_sym].nil?
        keys = []
        catalog[service.to_sym].keys.each { |x| keys << x.to_s }
        return keys.sort.first.to_s
      end
    end
  end
end
