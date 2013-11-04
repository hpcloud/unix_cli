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
    class RuleHelper < BaseHelper
      attr_accessor :id, :source, :protocol, :from, :to, :name
      attr_accessor :tenant_id, :type, :direction, :cidr

      def self.get_keys()
        return [ "id", "source", "type", "protocol", "direction", "cidr", "from", "to" ]
      end

      def initialize(connection, security_group, foggy = nil)
        super(connection, foggy)
        @security_group = security_group
        return if foggy.nil?
        @id = foggy['id']
        @name = foggy['remote_group_id']
        @source = @name
        @protocol = foggy['protocol']
        @direction = foggy['direction']
        @cidr = foggy['remote_ip_prefix']
        @tenant_id = foggy['tenant_id']
        @type = foggy['ethertype']
        @from = foggy['port_range_min']
        @to = foggy['port_range_max']
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          port_range = @from.to_s + ".." + @to.to_s
          response = @security_group.fog.create_rule(port_range, @protocol, @name)
          if response.nil?
            set_error("Error creating rule")
            return false
          end
          @fog = response.body["security_group_rule"]
          @id = @fog['id']
          return true
        else
          raise "Update not implemented"
        end
      end

      def destroy
        @fog.destroy
      end
    end
  end
end
