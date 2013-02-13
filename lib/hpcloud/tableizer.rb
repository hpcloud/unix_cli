module HP
  module Cloud

    class Tableizer

      def initialize(options, keys, values)
        @options = options
        columns = Columns.new(options, keys)
        @keys = columns.keys
        @values = values
      end

      def print
        return if @values.nil?
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
