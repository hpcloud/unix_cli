require 'fog/core/model'

module Fog
  module HP
    class LB
      class Algorithm < Fog::Model

        identity :name

        
        def to_hash
          Hash[@attributes.map{ |k, v| [k.to_s, v] }]
        end

      end

    end
  end
end
