require 'hpcloud/metadata'

module HP
  module Cloud
    class ServerHelper
      attr_reader :meta, :fog
      attr_accessor :error_string, :error_code, :meta
      attr_accessor :id, :name, :flavor, :image, :public_ip, :private_ip, :keyname, :security_groups, :security, :created, :state
    
      def self.get_keys()
        return [ "id", "name", "flavor", "image", "public_ip", "private_ip", "keyname", "security_groups", "created", "state" ]
      end 
        
      def initialize(compute, s = nil)
        @compute = compute
        @error_string = nil
        @error_code = nil
        @fog = s
        if s.nil?
          @meta = HP::Cloud::Metadata.new(nil)
          return
        end
        @id = s.id
        @name = s.name
        @flavor = s.flavor_id
        @image = s.image_id
        @public_ip = s.public_ip_address
        @private_ip = s.private_ip_address
        @keyname = s.key_name
        unless s.security_groups.nil?
          @security_groups = s.security_groups.map {|sg| sg["name"]}.join(', ')
        end
        @created = s.created_at
        @state = s.state
        @meta = HP::Cloud::Metadata.new(s.metadata)
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

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
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
        if @fog.nil?
          hsh = {:flavor_id => @flavor,
             :image_id => @image,            
             :name => @name,                
             :key_name => @keyname,        
             :security_groups => @security,  
             :metadata => @meta.hsh}
          server = @compute.servers.create(hsh)
          if server.nil?
            @error_string = "Error creating server '#{@name}'"
            @error_code = :general_error
            return false
          end
          @id = server.id
          @fog = server
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