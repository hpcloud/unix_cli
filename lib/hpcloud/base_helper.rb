module HP
  module Cloud
    class BaseHelper
      attr_accessor :error_string, :error_code, :fog, :connection

      def initialize(connection, foggy = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = foggy
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
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
