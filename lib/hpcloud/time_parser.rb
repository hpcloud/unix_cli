module HP
  module Cloud

    class TimeParser
      def self.parse(str)
          return nil if str.nil?
          ray = str.scan(/(\d+)(\w)/)
          if ray.nil? || ray[0].nil?
            raise Exception.new("The expected time format contains value and unit like 2d for two days.  Supported units are s, m, h, or d")
          end
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
            raise Exception.new("Unrecognized time unit #{ray[0][1]} in #{str} expected s, m, h, or d")
          end
      end
    end
  end
end
