module HP
  module Cloud

    class Rules

      # quick and dirty hack
      def self.table(rules)
        if (!rules.nil? && !rules.empty?)
          # draw out the header
          draw_header_line
          puts "  " +
               "| id" + padding(" ", 10, 'id') +
               "| ip_range/cidr" + padding(" ", 36, 'ip_range/cidr') +
               "| ip_protocol" + padding(" ", 25, 'ip_protocol') +
               "| from_port" + padding(" ", 13, 'from_port') +
               "| to_port" + padding(" ", 11, 'to_port') + "|"
          draw_header_line
          rules.each do |ip_perm|
            puts "  " +
                 "| #{ip_perm['id']}"   + padding(" ", 10, ip_perm['id'].to_s) +
                 "| #{ip_perm['ip_range']['cidr']}"    + padding(" ", 36, ip_perm['ip_range']['cidr'].to_s) +
                 "| #{ip_perm['ip_protocol']}" + padding(" ", 25, ip_perm['ip_protocol']) +
                 "| #{ip_perm['from_port']}"   + padding(" ", 13, ip_perm['from_port']) +
                 "| #{ip_perm['to_port']}"     + padding(" ", 11, ip_perm['to_port']) + "|"
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
        puts "  +" +
           padding("-", 12, 0) + "+" +
           padding("-", 38, 0) + "+" +
           padding("-", 27, 0) + "+" +
           padding("-", 15, 0) + "+" +
           padding("-", 13, 0) + "+"
      end
    end
  end
end