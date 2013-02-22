module HP
  module Cloud
    class Columns

      attr_reader :keys
    
      def initialize(options, keys)
        if options[:columns].nil?
          @keys = keys
        else
          @keys = options[:columns].split(',')
        end
      end

      def self.option_name
        return :columns
      end

      def self.option_args
        return { :type => :string, :aliases => '-c',
           :desc => 'Comma separated list of columns in report.'}
      end
    end
  end
end
