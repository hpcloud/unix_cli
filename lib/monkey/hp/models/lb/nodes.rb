require 'fog/core/collection'
require 'monkey/hp/models/lb/node'

module Fog
  module HP
    class LB
      class Nodes < Fog::Collection
        model Fog::HP::LB::Node

        def all
          data = service.list_load_balancer_nodes(@attributes[:parent_id]).body['nodes']
          load(data)
        end

        def get(record_id)
          record = service.get_load_balancer_node(@attributes[:parent_id], record_id).body['node']
          new(record)
        rescue Fog::HP::LB::NotFound
          nil
        end

      end
    end
  end
end
