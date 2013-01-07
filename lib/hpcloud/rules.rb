require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Rules < FogCollection
      def initialize(sec_group_name)
        super("rule")
        @security_group = SecurityGroups.new.get(sec_group_name)
        if @security_group.is_valid? == false
          raise Exception.new(@security_group.cstatus.to_s)
        end
        @items = @security_group.fog.rules
      end

      def create(item = nil)
        return RuleHelper.new(@connection, @security_group, item)
      end
    end
  end
end
