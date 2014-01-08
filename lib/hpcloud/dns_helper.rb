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
    class DnsHelper < BaseHelper
      attr_accessor :id, :name, :ttl, :serial, :email, :created_at
      attr_accessor :updated_at
    
      def self.get_keys()
        return [ "id", "name", "ttl", "serial", "email", "created_at" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        return if foggy.nil?
        foggy = Hash[foggy.map{ |k, v| [k.to_sym, v] }]
        @id = foggy[:id]
        @name = foggy[:name]
        @ttl = foggy[:ttl]
        @serial = foggy[:serial]
        @email = foggy[:email]
        @created_at = foggy[:created_at]
        @updated_at = foggy[:updated_at]
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:ttl => @ttl.to_i}
          dns = @connection.dns.create_domain(name, email, hsh)
          if dns.nil?
            set_error("Error creating dns '#{@name}'")
            return false
          end
          hash = dns.body
          hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
          @id = hash[:id]
          @fog = dns
          return true
        end
        hsh = {:ttl => @ttl.to_i,
               :email => @email}
        @connection.dns.update_domain(@id, hsh)
        return true
      end

      def destroy
        @connection.dns.delete_domain(@id)
      end

      def server_keys
        ["id", "name", "created_at"]
      end

      def servers
        rsp = @connection.dns.get_servers_hosting_domain(@id)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        hash[:servers]
      end

      def record_keys
        ["id", "name", "type", "data", "priority", "created_at"]
      end

      def records
        rsp = @connection.dns.list_records_in_a_domain(@id)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        hash[:records]
      end

      def create_record(name, type, data, priority)
        rsp = @connection.dns.create_record(@id, name, type, data, priority)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        return hash
      end

      def get_record(target)
        rsp = @connection.dns.list_records_in_a_domain(@id)
        ray = rsp.body['records']
        hash = ray.select { |x| x['id'] == target }.first
        return nil if hash.nil?
        Hash[hash.map{ |k, v| [k.to_sym, v] }]
      end

      def update_record(target, type, data)
        record = get_record(target)
        return nil if record.nil?
        options = { :type => type, :data => data}
        rsp = @connection.dns.update_record(@id, record[:id], options)
        hash = rsp.body
        hash = Hash[hash.map{ |k, v| [k.to_sym, v] }]
        return hash
      end

      def delete_record(target)
        record = get_record(target)
        return false if record.nil?
        @connection.dns.delete_record(@id, record[:id])
        return true
      end
    end
  end
end
