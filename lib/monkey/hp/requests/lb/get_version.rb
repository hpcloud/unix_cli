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

        # Get details for existing database flavor instance
        #
        # ==== Parameters
        # * flavor_id<~Integer> - Id of the flavor to get
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #   * TBD

        def get_version(version_id)
          response = request(
            :expects => 200,
            :method  => 'GET',
            :path    => "/#{version_id}/",
            :version => true
          )
          response
        end

      end

      class Mock # :nodoc:all

        def get_version(version_id)
          unless version_id
            raise ArgumentError.new('version_id is required')
          end
          response = Excon::Response.new
          if version = list_versions.body['versions'].detect { |_| _['id'] == version_id }
            response.status = 200
            response.body   = {'version' => version}
            response
          else
            raise Fog::HP::LB::NotFound
          end

        end
      end
    end
  end
end