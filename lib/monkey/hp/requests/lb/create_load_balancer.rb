module Fog
  module HP
    class LB
      class Real
        def create_load_balancer(name, nodes, options={})
          data = {
            "name"  => name,
            "nodes" => nodes
          }
          data['port'] = options['port'] if options['port']
          data['protocol'] = options['protocol'] if options['protocol']
          data['algorithms'] = options['algorithms'] if options['algorithms']
          if options['virtualIps']
            data['virtualIps'] = []
            for vip in options['virtualIps']
              data['virtualIps'] << vip
            end
          end

          response = request(
            :body    => Fog::JSON.encode(data),
            :expects => 202,
            :method  => 'POST',
            :path    => "loadbalancers"
          )
          response

        end
      end
      class Mock
        def create_load_balancer(name, nodes, options={})
          response = Excon::Response.new


          response
        end
      end
    end
  end
end
