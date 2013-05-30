require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Flavors < FogCollection
      def initialize()
        super("flavor")
        @items = @connection.compute.flavors.all(:details=>true)
      end

      def matches(arg, item)
        name = item.name.to_s
        shortname = name.gsub(/standard\./,'')
        return ((arg == item.id.to_s) || (arg == name) || (arg == shortname))
      end 

    end
  end
end
