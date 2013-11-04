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
    class AddressHelper < BaseHelper
      attr_accessor :id, :ip, :fixed_ip, :instance_id
    
      def self.get_keys()
        return [ "id", "ip", "fixed_ip", "instance_id" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        @id = foggy.id
        @ip = foggy.ip
        @fixed_ip = foggy.fixed_ip
        @instance_id = foggy.instance_id
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          address = @connection.compute.addresses.create
          if address.nil?
            set_error("Error creating ip address")
            return false
          end
          @id = address.id
          @ip = address.ip
          @fixed_ip = address.fixed_ip
          @fog = address
          return true
        else
          raise "Update not implemented"
        end
      end

      def name=(value)
        ip = value
      end
    end
  end
end
