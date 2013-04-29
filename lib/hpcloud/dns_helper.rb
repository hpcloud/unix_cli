module HP
  module Cloud
    class DnsHelper < BaseHelper
      attr_accessor :id, :name, :ttl, :serial, :email, :created_at
      attr_accessor :updated_at
    
      def self.get_keys()
        return [ "id", "name", "ttl", "serial", "email", "created_at" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        foggy = Hash[foggy.map{ |k, v| [k.to_sym, v] }]
        @id = foggy[:id]
        @name = foggy[:name]
        @ttl = foggy[:ttl]
        @serial = foggy[:serial]
        @email = foggy[:email]
        @created_at = foggy[:created_at]
        @updated_at = foggy[:updated_at]
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:ttl => @ttl.to_i,
                 :email => @email}
          dns = @connection.dns.create_domain(name, hsh)
          if dns.nil?
            set_error("Error creating dns '#{@name}'")
            return false
          end
          hash = dns.body
          hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
          @id = hash[:id]
          @fog = dns
          return true
        end
        hsh = {:ttl => @ttl.to_i,
               :email => @email}
        @connection.dns.update_domain(@id, hsh)
        return true
      end

      def destroy
        @connection.dns.delete_domain(@id)
      end

      def server_keys
        ["id", "name", "created_at"]
      end

      def servers
        rsp = @connection.dns.get_servers_hosting_domain(@id)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        hash[:servers]
      end

      def record_keys
        ["id", "name", "type", "data", "created_at"]
      end

      def records
        rsp = @connection.dns.list_records_in_a_domain(@id)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        hash[:records]
      end
    end
  end
end
