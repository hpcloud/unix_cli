module HP
  module Cloud
    class RuleHelper < BaseHelper
      attr_accessor :id, :source, :protocol, :from, :to, :cidr, :name

      def self.get_keys()
        return [ "id", "source", "protocol", "from", "to" ]
      end

      def initialize(connection, security_group, foggy = nil)
        super(connection, foggy)
        @security_group = security_group
        return if foggy.nil?
        @id = foggy['id']
        if foggy['group'].empty?
          @source = foggy['ip_range']['cidr']
          @cidr = foggy['ip_range']['cidr']
        else
          @source = foggy['group']['name']
          @name = foggy['group']['name']
        end
        @protocol = foggy['ip_protocol']
        @from = foggy['from_port']
        @to = foggy['to_port']
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          port_range = @from.to_s + ".." + @to.to_s
          response = @security_group.fog.create_rule(port_range, @protocol, @cidr, @name)
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
    end
  end
end
