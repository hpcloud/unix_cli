require 'hpcloud/remote_resource.rb'

module HP
  module Cloud
    class ContainerResource < RemoteResource
      def parse
        unless @fname.index('/').nil?
          raise Exception.new("Valid container names do not contain the '/' character: #{@fname}")
        end
        @fname = ':' + @fname  if @fname[0,1] != ':'
        super
      end

      def valid_virtualhost?
        return false if @container.nil?
        if (1..63).include?(@container.length)
          if @container =~ /^[a-z0-9-]*$/
            if @container[0,1] != '-' and @container[-1,1] != '-'
              return true 
            end
          end
        end
        false
      end

    end
  end
end
