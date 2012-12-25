module HP
  module Cloud
    class BaseHelper
      attr_accessor :fog, :connection, :cstatus

      def initialize(connection, foggy = nil)
        @connection = connection
        @cstatus = CliStatus.new
        @fog = foggy
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def set_error(noo, status = :general_error)
        unless noo.is_a?(CliStatus)
          noo = CliStatus.new(noo, status)
        end
        @cstatus.set(noo)
      end

      def is_valid?
        return @cstatus.is_success?
      end

      def destroy
        @fog.destroy unless @fog.nil?
      end
    end
  end
end
