module HP
  module Cloud

    class Tableizer

      def initialize(options, keys, values)
        @options = options
        @keys = keys
        @values = values
      end

      def print
        return if @values.nil?
        Formatador.display_compact_table(@values, @keys)
      end
    end
  end
end
