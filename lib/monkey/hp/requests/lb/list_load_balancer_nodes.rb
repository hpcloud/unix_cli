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
        def list_load_balancer_nodes(load_balancer_id)
          response = request(
            :expects => 200,
            :method  => 'GET',
            :path    => "loadbalancers/#{load_balancer_id}/nodes"
          )
          response
        end
      end
      class Mock
        def list_load_balancer_nodes(load_balancer_id)
          response = Excon::Response.new
          if lb = find_load_balancer(load_balancer_id)
            response.status = 200
            response.body   = {
              "nodes" => [
                {
                  "id"        => "410",
                  "address"   => "10.1.1.1",
                  "port"      => "80",
                  "condition" => "ENABLED",
                  "status"    => "ONLINE"
                },
                {
                  "id"        => "236",
                  "address"   => "10.1.1.2",
                  "port"      => "80",
                  "condition" => "ENABLED",
                  "status"    => "ONLINE"
                },
                {
                  "id"        => "2815",
                  "address"   => "10.1.1.3",
                  "port"      => "83",
                  "condition" => "DISABLED",
                  "status"    => "OFFLINE"
                },
              ]
            }
          else
            raise Fog::HP::LB::NotFound
          end

          response

        end

        def find_load_balancer(record_id)
          list_load_balancers.body['loadBalancers'].detect { |_| _['id'] == record_id }
        end
      end
    end
  end
end
