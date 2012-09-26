module HP
  module Cloud
    class KeypairHelper
      attr_accessor :error_string, :error_code, :fog
      attr_accessor :id, :name, :fingerprint, :public_key, :private_key
    
      def self.get_keys()
        return [ "name", "fingerprint" ]
      end

      def initialize(connection, keypair = nil)
        @connection = connection
        @error_string = nil
        @error_code = nil
        @fog = keypair
        return if keypair.nil?
        @id = keypair.name
        @name = keypair.name
        @fingerprint = keypair.fingerprint
        @public_key = keypair.public_key
        @private_key = keypair.private_key
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          if @public_key.nil?
            hsh = {:name => @name, :fingerprint => @fingerprint, :private_key => @private_key}
            keypair = @connection.compute.key_pairs.create(hsh)
          else
            keypair = @connection.compute.create_key_pair(@name, @public_key)
          end
          if keypair.nil?
            @error_string = "Error creating ip keypair"
            @error_code = :general_error
            return false
          end
          @fog = keypair
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
