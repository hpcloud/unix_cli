module HP
  module Cloud
    class RuleHelper
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :source, :protocol, :from, :to, :cidr, :name

      def self.get_keys()
        return [ "id", "source", "protocol", "from", "to" ]
      end

      def initialize(connection, security_group, rule = nil)
        @connection = connection
        @security_group = security_group
        @error_string = nil
        @error_code = nil
        @fog = rule
        return if rule.nil?
        @id = rule['id']
        if rule['group'].empty?
          @source = rule['ip_range']['cidr']
          @cidr = rule['ip_range']['cidr']
        else
          @source = rule['group']['name']
          @name = rule['group']['name']
        end
        @protocol = rule['ip_protocol']
        @from = rule['from_port']
        @to = rule['to_port']
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          port_range = @from.to_s + ".." + @to.to_s
          response = @security_group.fog.create_rule(port_range, @protocol, @cidr, @name)
          if response.nil?
            @error_string = "Error creating rule"
            @error_code = :general_error
            return false
          end
          @fog = response.body["security_group_rule"]
          @id = @fog['id']
          return true
        else
          raise "Update not implemented"
        end
      end

      def is_valid?
        return @error_string.nil?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end
    end
  end
end
