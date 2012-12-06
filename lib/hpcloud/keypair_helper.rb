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
            @error_string = "Error creating keypair"
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

      def self.private_directory
        "#{ENV['HOME']}/.hpcloud/keypairs/"
      end

      def private_filename
        "#{KeypairHelper.private_directory}#{name}.pem"
      end

      def private_exists?
        File.exists?(private_filename)
      end

      def private_read
        filename = private_filename()
        @private_key = File.read(filename)
        @fog.private_key = @private_key unless @fog.nil?
      end

      def private_add
        directory = KeypairHelper.private_directory
        FileUtils.mkdir_p(directory)
        FileUtils.chmod(0700, directory)
        filename = private_filename()
        FileUtils.rm_f(filename)
        if @fog.nil?
          file = File.new(filename, "w")
          file.write(@private_key)
          file.close
        else
          @fog.write(filename)
        end
        FileUtils.chmod(0400, filename)
        return filename
      end

      def self.private_list
        ray = Dir.entries(KeypairHelper.private_directory)
        ray = ray.delete_if{|x| x == "."}
        ray = ray.delete_if{|x| x == ".."}
        ray = ray.delete_if{|x| x.match(/\.pem$/) == nil }
        ray.collect!{|x| x.gsub(/\.pem$/,'') }
        ray.sort
      end

      def private_remove
        filename = private_filename()
        FileUtils.rm(filename)
        filename
      end
    end
  end
end
