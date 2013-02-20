module HP
  module Cloud

    class Tableizer
      attr_reader :found

      def initialize(options, keys, values = [])
        @options = options
        columns = Columns.new(options, keys)
        @keys = columns.keys
        @values = values
        @found = false
        @page_length = Config.new.get_i(:report_page_length, 60)
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
