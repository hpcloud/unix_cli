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

require 'fog/core/model'

module Fog
  module HP
    class LB

      class LoadBalancer < Fog::Model
        identity :id
        attribute :name
        attribute :protocol
        attribute :port
        attribute :algorithm
        attribute :status
        attribute :nodes
        attribute :virtualIps
        attribute :created_at, :aliases => 'created'
        attribute :updated_at , :aliases => 'updated'

        def destroy
          requires :id
          service.delete_load_balancer(id)
          true
        end

        def ready?
          self.status == 'ACTIVE'
        end

        def save
          identity ? update : create
        end

        private

        def create
          merge_attributes(service.create_load_balancer(name, nodes, attributes).body)
          true
        end

        def update
          requires :id
          merge_attributes(service.update_load_balancer(id, attributes).body)
          true
        end

      end
    end
  end
end
