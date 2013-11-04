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

require 'hpcloud/fog_collection'

module HP
  module Cloud
    class Routers < FogCollection
      def initialize
        super("router")
        @items = @connection.network.routers
      end

      def unique(name)
        super(name)
        Fog::HP::Network::Router.new({:service => Connection.instance.network})
      end

      def self.parse_gateway(value)
        networks = Networks.new
        unless value.nil?
          unless value.empty?
            netty = networks.get(value)
            return netty
          end
          return nil
        end
        networks.items.each{ |x|
          if x.router_external == true
            return x
          end
        }
        raise HP::Cloud::Exceptions::General.new("Cannot find external network to use as gateway")
      end

    end
  end
end
