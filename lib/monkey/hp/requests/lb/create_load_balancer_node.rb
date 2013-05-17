module Fog
  module HP
    class LB
      class Real
        def create_load_balancer_node(load_balancer_id, options={})
          data = {}

          if options['nodes']
            data['nodes'] = []
            for node in options['nodes']
              data['nodes'] << node
            end
          end

          response = request(
            :body    => Fog::JSON.encode(data),
            :expects => 202,
            :method  => 'POST',
            :path    => "loadbalancers/#{load_balancer_id}/nodes"
          )

        end
      end
      class Mock
        def create_load_balancer_node(load_balancer_id, options={})
          response = Excon::Response.new


          response
        end
      end
    end

  end
end
