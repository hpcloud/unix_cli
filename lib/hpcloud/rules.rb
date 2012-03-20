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
               "| cidr/source_group" + padding(" ", 36, 'cidr/source_group') +
               "| ip_protocol" + padding(" ", 25, 'ip_protocol') +
               "| from_port" + padding(" ", 13, 'from_port') +
               "| to_port" + padding(" ", 11, 'to_port') + "|"
          draw_header_line
          rules.each do |rule|
            puts "  " +
                 "| #{rule['id']}"   + padding(" ", 10, rule['id'].to_s) +
                 "| #{cidr_srcgroup(rule)}" + padding(" ", 36, cidr_srcgroup(rule).to_s) +
                 "| #{rule['ip_protocol']}" + padding(" ", 25, rule['ip_protocol']) +
                 "| #{rule['from_port']}"   + padding(" ", 13, rule['from_port']) +
                 "| #{rule['to_port']}"     + padding(" ", 11, rule['to_port']) + "|"
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

      def self.cidr_srcgroup(rule)
        rule['group'].empty? ? rule['ip_range']['cidr'] : rule['group']['name']
      end
    end
  end
end