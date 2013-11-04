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

module HP
  module Cloud
    class NetworkHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id, :status, :subnets, :subnets_array
      attr_accessor :shared, :admin_state_up, :router_external
      attr_accessor :admin_state
    
      def self.get_keys()
        return [ "id", "name", "status", "shared", "admin_state", "subnets" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        @shared = false
        @admin_state_up = true
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @tenant_id = foggy.tenant_id
        @status = foggy.status
        @shared = foggy.shared
        @admin_state_up = foggy.admin_state_up
        @admin_state = foggy.admin_state_up ? "up" : "down"
        @subnets_array = foggy.subnets
        @subnets = ''
        unless foggy.subnets.nil?
          foggy.subnets.each{ |x|
            @subnets = ',' unless @subnets.empty?
            @subnets = x.id.to_s
          }
        end
        @router_external = foggy.router_external
      end

      def save
        return false if is_valid? == false
        hsh = {:name => @name,
           :tenant_id => @tenant_id,
           :shared => @shared.to_s,
           :admin_state_up => @admin_state_up.to_s}
        if @fog.nil?
          response = @connection.network.create_network(hsh)
          if response.nil?
            set_error("Error creating network '#{@name}'")
            return false
          end
          @id = response.body["network"]["id"]
          @status = response.body["network"]["status"]
          @foggy = response.body["network"]
        else
          response = @connection.network.update_network(@id, hsh)
          if response.nil?
            set_error("Error updating network '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_network(@id)
      end
    end
  end
end
