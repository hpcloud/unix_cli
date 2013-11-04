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
    class SubnetHelper < BaseHelper
      attr_accessor :id, :name, :tenant_id
      attr_accessor :network_id, :cidr, :ip_version, :dns_nameservers
      attr_accessor :allocation_pools, :host_routes, :gateway, :dhcp
      attr_accessor :allocation, :routes, :nameservers
    
      def self.get_keys()
        return [ "id", "name", "network_id", "cidr", "nameservers", "routes", "gateway", "dhcp" ]
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
        @cidr = foggy.cidr
        @ip_version = foggy.ip_version
        @dns_nameservers = foggy.dns_nameservers
        @nameservers = ""
        if foggy.dns_nameservers.kind_of? Array
          @nameservers = foggy.dns_nameservers.join(",")
        end
        @allocation_pools = foggy.allocation_pools
        @allocation = ""
        if foggy.allocation_pools.kind_of? Array
          foggy.allocation_pools.each { |hsh|
            if hsh.kind_of? Hash
              @allocation += "," unless @allocation.empty?
              @allocation += "#{hsh['start']}-#{hsh['end']}"
            end
          }
        end
        @host_routes = foggy.host_routes
        @routes = ""
        if foggy.host_routes.kind_of? Array
          foggy.host_routes.each{ |route|
            if route.kind_of? Hash
              @routes += ';' unless @routes.empty?
              @routes += "#{route['destination']},#{route['nexthop']}"
            end
          }
        end
        @gateway = foggy.gateway_ip
        @dhcp = foggy.enable_dhcp
      end

      def set_cidr(value)
        require 'ipaddr'
        @cidr = value
        begin
          ipaddr = IPAddr.new(@cidr)
          @ip_version = 6 if ipaddr.ipv6?
          @ip_version = 4 if ipaddr.ipv4?
        rescue Exception => e
          set_error("Invalid CIDR value #{@cidr}", :incorrect_usage)
          return false
        end
        return true
      end

      def set_ip_version(value)
        return true if value.nil?
        value = value.to_s
        if value != "4" && value != "6"
          set_error("Invalid IP version '#{value}'", :incorrect_usage)
          return false
        end
        @ip_version = value
        return true
      end

      def set_gateway(value)
        @gateway = value
      end

      def set_dns_nameservers(value)
        return true if value.nil?
        require 'ipaddr'
        @nameserver = value
        begin
          @dns_nameservers = value.split(',')
          @dns_nameservers.each{ |dns|
            IPAddr.new(dns)
          }
        rescue Exception => e
          set_error("Invalid DNS nameserver '#{value}' must be comma separated list of IPs", :incorrect_usage)
          return false
        end
        return true
      end

      def set_host_routes(value)
        return true if value.nil?
        @routes = value
        begin
          @host_routes = []
          value.split(';').each{ |route|
            ray = route.split(',')
            raise Exception.new("not destination,nexthop") if ray.length != 2
            @host_routes << { "destination" => ray[0], "nexthop" => ray[1] }
          }
        rescue Exception => e
          set_error("Invalid host routes '#{value}' must be semicolon separated list of destination,nexthop", :incorrect_usage)
          return false
        end
        return true
      end

      def save
        return false if is_valid? == false
        hsh = {
            :name => @name,
            :tenant_id => @tenant_id,
            :dns_nameservers => @dns_nameservers,
            :allocation_pools => @allocation_pools,
            :host_routes => @host_routes,
            :gateway_ip => @gateway,
            :enable_dhcp => @dhcp.to_s
          }
        if @fog.nil?
          response = @connection.network.create_subnet(@network_id, @cidr, @ip_version, hsh)
          if response.nil?
            set_error("Error creating subnet '#{@name}'")
            return false
          end
          @id = response.body["subnet"]["id"]
          @foggy = response.body["subnet"]
        else
          response = @connection.network.update_subnet(@id, hsh)
          if response.nil?
            set_error("Error updating subnet '#{@name}'")
            return false
          end
        end
        return true
      end

      def destroy
        @connection.network.delete_subnet(@id)
      end
    end
  end
end
