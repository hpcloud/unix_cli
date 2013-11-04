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

require 'hpcloud/commands/cdn_containers/add'
require 'hpcloud/commands/cdn_containers/remove'
require 'hpcloud/commands/cdn_containers/set'
require 'hpcloud/commands/cdn_containers/get'
require 'hpcloud/commands/cdn_containers/location'

module HP
  module Cloud
    class CLI < Thor

      map 'cdn:containers:list' => 'cdn:containers'

      desc "cdn:containers", "List available containers on the CDN."
      long_desc <<-DESC
  List the available containers on the content delivery network (CDN). Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers                    # List only the CDN-enabled containers
  hpcloud cdn:containers -l                 # List all the container on the CDN
  hpcloud cdn:containers -z region-a.geo-1  # List only the CDN-enabled containers for availability zone `region-a.geo-1`

Aliases: cdn:containers:list
      DESC
      method_option :all, :default => false,
                    :type => :boolean, :aliases => '-l',
                    :desc => 'List all the CDN containers, either enabled or disabled.'
      CLI.add_common_options
      define_method "cdn:containers" do
        cli_command(options) {
          begin
            response = if options[:all]
              Connection.instance.cdn.get_containers()
            else
              Connection.instance.cdn.get_containers({'enabled_only' => true})
            end
            cdn_containers = response.body
            if cdn_containers.nil? or cdn_containers.empty?
              @log.display "You currently have no containers on the CDN."
            else
              cdn_containers.each { |cdn_container|
                @log.display cdn_container['name']
              }
            end
          rescue Fog::CDN::HP::NotFound => e
            @log.display "You currently have no containers on the CDN."
          end
        }
      end
    end
  end
end
