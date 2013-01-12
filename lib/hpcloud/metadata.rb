require 'csv'

module HP
  module Cloud
    class Metadata
      attr_reader :cstatus, :hsh
    
      def self.get_keys()
        return [ "key", "value" ]
      end

      def initialize(mta = nil)
        @cstatus = CliStatus.new
        @fog_metadata = mta
        @hsh = {}
        if mta.nil?
          return
        end
        mta.map { |m| @hsh["#{m.key}"] = "#{m.value}" }
      end

      def to_array()
        ray = []
        @hsh.each { |k,v| ray << {"key"=>k,"value"=>v} }
        ray.sort!{|a, b| a["key"] <=> b["key"]}
        return ray
      end

      def set_metadata(value)
        if value.nil?
          return true
        end
        if value.empty?
          @hsh = {}
          return true
        end
        begin
          hshstr = '{"' + value.gsub('=', '"=>"').gsub(',', '","') + '"}'
          hsh = eval(hshstr)
          if (hsh.kind_of? Hash)
            @hsh = hsh
            unless @fog_metadata.nil?
              @hsh.each { |k,v|
                pair = @fog_metadata.get(k)
                if pair.nil?
                  pair = @fog_metadata.new
                  pair.key = k
                  pair.value = v
                else
                  pair.value = v
                end
                pair.save
              }
            end
            return true
          end
        rescue SyntaxError => se
        rescue NameError => ne
        end
        @cstatus = CliStatus.new("Invalid metadata '#{value}' should be in the form 'k1=v1,k2=v2,...'", :incorrect_usage)
        return false
      end

      def remove_metadata(key)
        pair = nil
        if ! @fog_metadata.nil?
          pair = @fog_metadata.get(key)
        end
        if pair.nil?
          @cstatus = CliStatus.new("Metadata key '#{key}' not found", :not_found)
        else
          begin
            pair.destroy
          rescue Exception => e
            @cstatus = CliStatus.new("Error deleting metadata '#{key}': " + e.message)
          end
        end
        if @cstatus.is_success?
          return true
        end
        return false
      end

      def to_s
        found=false
        metadata=""
        ray = to_array()
        ray.each { |val|
          metadata << "," unless found == false
          metadata << val["key"].to_s + "=" + val["value"].to_s
          found = true
        }
        return metadata
      end
    end
  end
end
