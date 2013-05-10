module HP
  module Cloud
    class LbHelper < BaseHelper
      attr_accessor :id, :name, :algorithm, :protocol, :port, :status
      attr_accessor :created, :updated
    
      def self.get_keys()
        return [ "id", "name", "algorithm", "protocol", "port", "status" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        foggy = Hash[foggy.map{ |k, v| [k.to_sym, v] }]
        @id = foggy[:id]
        @name = foggy[:name]
        @algorithm = foggy[:algorithm]
        @protocol = foggy[:protocol]
        @port = foggy[:port]
        @status = foggy[:status]
        @created = foggy[:created]
        @updated = foggy[:updated]
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:algorithm => @algorithm,
                 :protocol => @protocol,
                 :port => @port}
          lb = @connection.lb.create_load_balancer(name, hsh)
          if lb.nil?
            set_error("Error creating lb '#{@name}'")
            return false
          end
          hash = lb.body
          hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
          @id = hash[:id]
          @fog = lb
          return true
        end
        hsh = {:algorithm => @algorithm,
               :protocol => @protocol,
               :port => @port}
        @connection.lb.update_load_balancer(@id, hsh)
        return true
      end

      def destroy
        @connection.lb.delete_load_balancer(@id)
      end
    end
  end
end
