# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module Fog
  module HP
    class LB
      class Real

        def delete_load_balancer_node(instance_id, node_id)
          response = request(
            :expects => [204,202],
            :method  => 'DELETE',
            :path    => "loadbalancers/#{instance_id}/nodes/#{node_id}"
          )
          response
        end

      end
      class Mock

        def delete_load_balancer_node(instance_id, node_id)
          response = Excon::Response.new
          response = Excon::Response.new
          if load_b = get_load_balancer(instance_id).body
            if node = find_node(load_b, node_id)
              response.status = 202
            else
              raise Fog::HP::LB::NotFound
            end
          else
            raise Fog::HP::LB::NotFound
          end
          response
        end

        def find_node(lb, node_id)
          lb['nodes'].detect { |_| _['id'] == node_id }
        end
      end
    end
  end
end
