require 'fog/core/model'

module Fog
  module HP
    class LB
      class Node < Fog::Model

        identity :id
        attribute :address
        attribute :port
        attribute :condition
        attribute :status
        attribute :load_balancer_id

        def destroy
          requires :id
          service.delete_load_balancer_node(load_balancer_id, id)
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
          merge_attributes(service.create_load_balancer_node(load_balancer_id, {'nodes' => [attributes]}).body)
          true
        end

        def update
          requires :id
          merge_attributes(service.update_load_balancer_node(load_balancer_id, id, attributes).body)
          true
        end

      end
    end
  end
end
