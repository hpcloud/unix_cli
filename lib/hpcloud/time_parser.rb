module HP
  module Cloud

    class TimeParser
      def self.parse(str)
        begin
          ray = str.scan(/(\d+)(\w)/)
          case ray[0][1]
          when "s"
            return ray[0][0].to_i
          when "m"
            return ray[0][0].to_i * 60
          when "h"
            return ray[0][0].to_i * 60 * 60
          when "d"
            return ray[0][0].to_i * 60 * 60 * 24
          else
            raise Exception.new("Unrecognized")
          end
        rescue Exception => e
          raise Exception.new("Error parsing time period: #{str}")
        end
      end
    end
  end
end
