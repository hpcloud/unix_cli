module HP
  module Cloud

    class IpPermissions

      # quick and dirty hack
      def self.table(ip_permissions)
        if (!ip_permissions.nil? && !ip_permissions.empty?)
          # draw out the header
          draw_header_line
          puts "  | groups" + padding(" ", 25, 'groups') +"| ip_ranges" + padding(" ", 36, 'ip_ranges')+ "| ip_protocol" + padding(" ", 13, 'ip_protocol')+"| from_port" + padding(" ", 11, 'from_port') + "| to_port" + padding(" ", 11, 'to_port') + "|"
          draw_header_line
          ip_permissions.each do |ip_perm|
            puts "  | #{ip_perm['groups']}"   + padding(" ", 25, ip_perm['groups'].to_s) +
                 "| #{ip_perm['ipRanges']}"   + padding(" ", 36, ip_perm['ipRanges'].to_s) +
                 "| #{ip_perm['ipProtocol']}" + padding(" ", 13, ip_perm['ipProtocol']) +
                 "| #{ip_perm['fromPort']}"   + padding(" ", 11, ip_perm['fromPort']) +
                 "| #{ip_perm['toPort']}"     + padding(" ", 11, ip_perm['toPort']) + "|"
            draw_header_line
          end
        end
      end

      def self.padding(pad_char, header_length, value)
        pad_char * (header_length-length(value)).abs
      end

      def self.length(value)
        if value.is_a?(Fixnum)
          value.nil? ? 0 : value.to_s.length
        else
          value.nil? ? 0 : value.length
        end
      end

      def self.draw_header_line
        puts "  +" + padding("-", 27, 0) +"+" + padding("-", 38, 0)+ "+" + padding("-", 15, 0) + "+" + padding("-", 13, 0) + "+" + padding("-", 13, 0) + "+"
      end
    end
  end
end