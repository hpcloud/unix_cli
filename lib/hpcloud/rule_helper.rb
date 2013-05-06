module HP
  module Cloud
    class RuleHelper < BaseHelper
      attr_accessor :id, :source, :protocol, :from, :to, :name
      attr_accessor :tenant_id, :type, :direction, :remote_ip_prefix

      def self.get_keys()
        return [ "id", "source", "type", "protocol", "direction", "remote_ip_prefix", "from", "to" ]
      end

      def initialize(connection, security_group, foggy = nil)
        super(connection, foggy)
        @security_group = security_group
        return if foggy.nil?
        @id = foggy['id']
        @name = foggy['remote_group_id']
        @source = @name
        @protocol = foggy['protocol']
        @direction = foggy['direction']
        @remote_ip_prefix = foggy['remote_ip_prefix']
        @tenant_id = foggy['tenant_id']
        @type = foggy['ethertype']
        @from = foggy['port_range_min']
        @to = foggy['port_range_max']
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          port_range = @from.to_s + ".." + @to.to_s
          response = @security_group.fog.create_rule(port_range, @protocol, @name)
          if response.nil?
            set_error("Error creating rule")
            return false
          end
          @fog = response.body["security_group_rule"]
          @id = @fog['id']
          return true
        else
          raise "Update not implemented"
        end
      end

      def destroy
        @fog.destroy
      end
    end
  end
end
