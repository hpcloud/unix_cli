require 'hpcloud/metadata'

module HP
  module Cloud
    class ServerHelper < BaseHelper
      attr_reader :private_key, :windows
      attr_accessor :id, :name, :flavor, :image, :public_ip, :private_ip, :keyname, :security_groups, :security, :created, :state, :volume, :meta
    
      def self.get_keys()
        return [ "id", "name", "flavor", "image", "public_ip", "private_ip", "keyname", "security_groups", "created", "state" ]
      end 
        
      def initialize(connection, foggy = nil)
        super(connection, foggy)
        @windows = false
        @private_image = false
        if foggy.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = foggy.id
        @name = foggy.name
        @flavor = foggy.flavor_id
        @image = foggy.image_id
        @public_ip = foggy.public_ip_address
        @private_ip = foggy.private_ip_address
        @keyname = foggy.key_name
        unless foggy.security_groups.nil?
          @security_groups = foggy.security_groups.map {|sg| sg["name"]}.join(', ')
        end
        @created = foggy.created_at
        @state = foggy.state
        @meta = HP::Cloud::Metadata.new(foggy.metadata)
      end

      def set_flavor(value)
        flav = Flavors.new.get(value, false)
        unless flav.is_valid?
          @error_string = flav.error_string
          @error_code = flav.error_code
          return false
        end
        @flavor = flav.id
        return true
      end

      def set_image(value)
        return true if value.nil?
        @windows = false
        @private_image = false
        image = Images.new().get(value, false)
        unless image.is_valid?
          @error_string = image.error_string
          @error_code = image.error_code
          return false
        end
        @windows = image.is_windows?
        @private_image = image.is_private?
        @image = image.id
        return true
      end

      def set_volume(value)
        return true if value.nil?
        @windows = false # windows not supported right now
        volume = Volumes.new().get(value, false)
        unless volume.is_valid?
          @error_string = volume.error_string
          @error_code = volume.error_code
          return false
        end
        @volume = volume.id
        return true
      end

      def set_keypair(value)
        if value.nil?
          return true
        end
        @keypair = Keypairs.new.get(value, false)
        unless @keypair.is_valid?
          @error_string = @keypair.error_string
          @error_code = @keypair.error_code
          return false
        end
        @keyname = @keypair.name
        if @windows
          begin
            @private_key = @keypair.private_read
          rescue
          end
        end
        return true
      end

      def set_security_groups(value)
        if value.nil?
          return true
        end
        if value.empty?
          @security = []
          @security_groups = ''
          return true
        end
        begin
          ray = eval("[\"" + value.gsub(',', '","') + "\"]")
          if (ray.kind_of? Array)
            @security = ray
            @security_groups = value
            return true
          end
        rescue SyntaxError => se
        rescue NameError => ne
        end
        @error_string = "Invalid security group '#{value}' should be comma separated list"
        @error_code = :incorrect_usage
        return false
      end

      def set_private_key(value)
        if value.nil?
          return true unless @windows
          return true unless @private_key.nil?
          @error_string = "You must specify the private key file if you want to create a windows instance."
          @error_code = :incorrect_usage
          return false
        end
        begin
          @private_key = File.read(File.expand_path(value))
        rescue Exception => e
          @error_string = "Error reading private key file '#{value}': " + e.to_s
          @error_code = :incorrect_usage
          return false
        end
        return true
      end

      def windows_password(retries=10)
        begin
          (0..retries).each { |x|
            @epass = @fog.windows_password()
            break unless @epass.empty?
            sleep (x*10) unless retries == 1
          }
          return "Failed to get password" if @epass.empty?
          begin
            private_key = OpenSSL::PKey::RSA.new(@private_key)
            from_base64 = Base64.decode64(@epass)
            return private_key.private_decrypt(from_base64).strip
          rescue Exception => error
          end
          return "Failed to decrypt: " + @epass
        rescue Exception => e
          return "Error getting windows password: " + e.to_s
        end
      end

      def create_image(name, hash)
        resp = @fog.create_image(name , hash)
        if resp.nil?
          @error_string = "Error creating image '#{name}'"
          @error_code = :general_error
          return nil
        end
        return resp.headers["Location"].gsub(/.*\/images\//,'')
      end

      def save
        if is_valid?
          @error_string = @meta.error_string
          @error_code = @meta.error_code
        end
        return false if is_valid? == false
        acct = Accounts.new.get(Connection.instance.get_account)
        @flavor = acct[:options][:preferred_flavor] if @flavor.nil?
        @image = acct[:options][:preferred_image] if @image.nil?  && @volume.nil?
        if @image.nil? && @volume.nil?
          @error_string = "You must specify either an image or a volume to create a server."
          @error_code = :incorrect_usage
          return false
        end
        if @fog.nil?
          hsh = {:flavor_id => @flavor,
             :name => @name,
             :key_name => @keyname,
             :security_groups => @security,
             :metadata => @meta.hsh}
          unless @image.nil?
            hsh[:image_id] = @image
          end
          unless @volume.nil?
            hsh[:block_device_mapping] = [{
                     'volume_size' => '',
                     'volume_id' => "#{@volume}",
                     'delete_on_termination' => '0',
                     'device_name' => 'vda'
                   }]
          end
          server = @connection.servers.create(hsh)
          if server.nil?
            @error_string = "Error creating server '#{@name}'"
            @error_code = :general_error
            return false
          end
          @id = server.id
          @fog = server
          begin
            unless @keypair.nil?
              @keypair.private_read if @keypair.private_key.nil?
              @keypair.name = "#{@id}"
              @keypair.private_add
            end
          rescue
          end
          return true
        else
          raise "Update not implemented"
        end
      end

      def is_windows?
        return @windows
      end

      def is_private_image?
        return @private_image
      end

      def destroy
        @fog.destroy unless @fog.nil?
        begin
          keypair = KeypairHelper.new(nil)
          keypair.name = "#{@id}"
          keypair.private_remove
        rescue Exception => e
        end
      end
    end
  end
end
