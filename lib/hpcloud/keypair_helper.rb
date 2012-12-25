module HP
  module Cloud
    class KeypairHelper < BaseHelper
      attr_accessor :id, :name, :fingerprint, :public_key, :private_key
    
      def self.get_keys()
        return [ "name", "fingerprint" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.name
        @name = foggy.name
        @fingerprint = foggy.fingerprint
        @public_key = foggy.public_key
        @private_key = foggy.private_key
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
            set_error("Error creating keypair")
            return false
          end
          @fog = keypair
          return true
        else
          raise "Update not implemented"
        end
      end

      def self.private_directory
        "#{ENV['HOME']}/.hpcloud/keypairs/"
      end

      def self.private_filename(name)
        "#{KeypairHelper.private_directory}#{name}.pem"
      end

      def private_read
        filename = KeypairHelper.private_filename(name)
        @private_key = File.read(filename)
        @fog.private_key = @private_key unless @fog.nil?
        @private_key
      end

      def private_add
        directory = KeypairHelper.private_directory
        FileUtils.mkdir_p(directory)
        FileUtils.chmod(0700, directory)
        filename = KeypairHelper.private_filename(name)
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
        filename = KeypairHelper.private_filename(name)
        FileUtils.rm(filename)
        filename
      end
    end
  end
end
