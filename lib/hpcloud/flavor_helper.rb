module HP
  module Cloud
    class FlavorHelper < BaseHelper
      attr_accessor :id, :name, :fullname, :ram, :disk
    
      def self.get_keys()
        return [ "id", "name", "ram", "disk" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.id
        @name = foggy.name.gsub(/standard\./,'')
        @fullname = foggy.name
        @ram = foggy.ram
        @disk = foggy.disk
      end

      def save
        set_status("Save of flavors not supported at this time", :general_error)
        return false
      end
    end
  end
end
