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
    class CLI < Thor

      desc "lb:add <name> <algorithm> <protocol> <port>", "Add a load balancer."
      long_desc <<-DESC
  Add a load balancer with the specified name, algorithm, protocol and port.  You must specify a node and may specify a virtual IP id to create a load balancer.

Examples:
  hpcloud lb:add loady ROUND_ROBIN HTTP 80 -n '10.1.1.1:80;10.1.1.2:81' -v '123;39393'        # Create a new load balancer 'loady'
      DESC
      method_option :nodes,
                    :type => :string, :aliases => '-n', :required => true,
                    :desc => 'Nodes to associate with the load balancer. Semicolon separated list of colon separated IP and port pairs'
      method_option :ips,
                    :type => :string, :aliases => '-v',
                    :desc => 'Semicolon separated list of of virtual IPs Ids to associate with the load balancer.'
      CLI.add_common_options
      define_method "lb:add" do |name, algorithm, protocol, port|
        cli_command(options) {
          lb = Lbs.new.unique(name)
          lb.name = name
          algorithm = LbAlgorithms.new.get(algorithm).name
          lb.algorithm = algorithm
          protocol = LbProtocols.new.get(protocol).name
          lb.protocol = protocol
          lb.port = port
          lb.nodes = parse_nodes(options[:nodes])
          lb.virtualIps = parse_virtual_ips(options[:ips])
          lb.save
          @log.display "Created load balancer '#{name}' with id '#{lb.id}'."
        }
      end

      private

      def parse_nodes(value)
        return [] if value.nil?
        ray = []
        begin
          value.split(';').each{ |x|
            hsh = {}
            nod = x.split(':')
            raise "Error" if nod.length != 2
            hsh["address"] = nod[0]
            hsh["port"] = nod[1]
            ray << hsh
          }
        rescue
          raise HP::Cloud::Exceptions::General.new("Error parsing nodes '#{value}'")
        end
        ray
      end

      def parse_virtual_ips(value)
        return [] if value.nil?
        ray = []
        begin
          value.split(';').each{ |x|
            ray << {"id"=>x}
          }
        rescue
          raise HP::Cloud::Exceptions::General.new("Error parsing virtual IPs '#{value}'")
        end
        ray
      end

    end
  end
end
