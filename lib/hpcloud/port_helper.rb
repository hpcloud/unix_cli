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
    class PortHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id
      attr_accessor :network_id, :fixed_ips, :mac_address, :status
      attr_accessor :admin_state_up, :device_id, :device_owner, :security_groups
      attr_accessor :admin_state, :groups
    
      def self.get_keys()
        return [ "id", "name", "network_id", "fixed_ips", "mac_address", "status", "admin_state", "device_id", "device_owner" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @tenant_id = foggy.tenant_id
        @network_id = foggy.network_id
        @fixed = foggy.fixed_ips
        @fixed_ips = ""
        if foggy.fixed_ips.kind_of? Array
          foggy.fixed_ips.each{ |pair|
            @fixed_ips += ";" unless @fixed_ips.empty?
            @fixed_ips += "#{pair['subnet_id']},#{pair['ip_address']}"
          }
        end
        @mac_address = foggy.mac_address
        @status = foggy.status
        @admin_state_up = foggy.admin_state_up
        @admin_state = foggy.admin_state_up ? "up" : "down"
        @device_id = foggy.device_id
        @device_owner = foggy.device_owner
        @groups = foggy.security_groups
        @security_groups = ""
        if foggy.security_groups.kind_of? Array
          @security_groups = foggy.security_groups.join(",")
        end
      end

      def set_fixed_ips(value)
        return true if value.nil?
        @fixed_ips = value
        begin
          @fixed = []
          value.split(';').each{ |subnet|
            ray = subnet.split(',')
            raise Exception.new("not subnet_id,ip_address") if ray.length != 2
            @fixed << { "subnet_id" => ray[0], "ip_address" => ray[1] }
          }
        rescue Exception => e
          set_error("Invalid fixed IPs '#{value}' must be semicolon separated list of subnet_id,ip_address", :incorrect_usage)
          return false
        end
        return true
      end

      def set_mac_address(value)
        return true if value.nil?
        @mac_address = value
      end

      def set_admin_state(value)
        return true if value.nil?
        @admin_state = value ? "up" : "down"
        @admin_state_up = value
      end

      def set_device_id(value)
        return true if value.nil?
        @device_id = value
      end

      def set_device_owner(value)
        return true if value.nil?
        @device_owner = value
      end

      def set_security_groups(value)
        return true if value.nil?
        @groups = value
        begin
          @security_groups = value.split(',')
        rescue Exception => e
          set_error("Invalid security groups '#{value}' must be comma separated list of groups", :incorrect_usage)
          return false
        end
        return true
      end

      def save
        return false if is_valid? == false
        hsh = {
            :name => @name,
            :tenant_id => @tenant_id,
            :network_id => @network_id,
            :fixed_ips => @fixed,
            :mac_address => @mac_address,
            :admin_state_up => @admin_state_up,
            :device_id => @device_id,
            :device_owner => @device_owner,
            :security_groups => @groups
          }
        if @fog.nil?
          response = @connection.network.create_port(@network_id, hsh)
          if response.nil?
            set_error("Error creating port '#{@name}'")
            return false
          end
          @id = response.body["port"]["id"]
          @foggy = response.body["port"]
        else
          response = @connection.network.update_port(@id, hsh)
          if response.nil?
            set_error("Error updating port '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_port(@id)
      end
    end
  end
end
