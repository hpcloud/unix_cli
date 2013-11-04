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

module HP
  module Cloud

    class Tableizer
      attr_reader :found

      DEFAULT_REPORT_PAGE_LENGTH = 60

      def initialize(options, keys, values = [])
        @options = options
        columns = Columns.new(options, keys)
        @keys = columns.keys
        @values = values
        @found = false
        @page_length = Config.new.get_i(:report_page_length, DEFAULT_REPORT_PAGE_LENGTH)
      end

      def add(item)
        @found = true
        @values << item
        print if @values.length >= @page_length
      end

      def print
        return if @values.nil?
        return if @values.empty?
        @found = true
        if @options[:separator]
          separator = @options[:separator]
          separator = ',' if separator == "separator"
          @values.each{ |v|
            sep = ''
            line = ''
            @keys.each{ |k|
              line += "#{sep}#{v[k]}"
              sep = separator
            }
            puts line
          }
        else
          Formatador.display_compact_table(@values, @keys)
        end
        @values = []
      end

      def self.option_name
        return :separator
      end

      def self.option_args
        return { :type => :string, :aliases => '-d',
           :desc => 'Use the specified value as the report separator.'}
      end
    end
  end
end
