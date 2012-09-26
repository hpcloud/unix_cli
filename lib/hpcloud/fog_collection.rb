module HP
  module Cloud
    class FogCollection
    
      def initialize(name, connection=nil)
        @name = name
        @connection = connection
        @connection = Connection.instance if connection.nil?
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.name.to_s))
      end

      def filter(arguments = [], multimatch=true)
        if @ray.nil?
          @ray = []
          @items.each { |x| @ray << create(x) }
        end
        if (arguments.empty?)
          return @ray
        end
        retray = []
        arguments.each { |arg|
          found = []
          @ray.each { |item|
            if matches(arg, item)
              if (multimatch == true)
                found << item
              else
                if found.length == 0
                  found << item
                else
                  found[0].error_string = "More than one #{@name} matches '#{arg}', use the id instead of name."
                  found[0].error_code = :general_error
                end
              end
            end
          }
          if found.length == 0
            item = create()
            item.name = arg
            item.error_string = "Cannot find a #{@name} matching '#{arg}'."
            item.error_code = :not_found
            retray << item
          else
            retray += found
          end
        }
        return retray
      end

      def get(arguments = [], multimatch=true)
        if arguments.kind_of?(Array)
          return filter(arguments, multimatch)
        end
        return filter([arguments], false).first
      end

      def get_hash(arguments = [])
        ray = []
        get(arguments, true).each { |x|
          if x.is_valid?
            ray << x.to_hash()
          end
        }
        return ray
      end

      def empty?
        return true if @items.nil?
        return @items.empty?
      end
    end
  end
end
