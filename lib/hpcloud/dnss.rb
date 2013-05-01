require 'hpcloud/fog_collection'
require 'hpcloud/dns_helper'

module HP
  module Cloud
    class Dnss < FogCollection
      def initialize
        super("dns")
        @items = @connection.dns.list_domains.body["domains"]
      end

      def create(item = nil)
        return DnsHelper.new(@connection, item)
      end
    end
  end
end
