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
        def create_load_balancer(name, nodes, options={})
          data = {
            "name"  => name,
            "nodes" => nodes
          }
          options = Hash[options.map{ |k, v| [k.to_s, v] }]
          data['port'] = options['port'] if options['port']
          data['protocol'] = options['protocol'] if options['protocol']
          data['algorithm'] = options['algorithm'] if options['algorithm']
          unless options['virtualIps'].nil?
            unless options['virtualIps'].empty?
              data['virtualIps'] = []
              for vip in options['virtualIps']
                data['virtualIps'] << vip
              end
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
