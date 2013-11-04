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

      desc "cdn:containers:get <name> [attribute..]", "Get the value of an attribute of a CDN container."
      long_desc <<-DESC
  Get the value of an attribute for an existing CDN container. The allowed attributes whose value can be retrieved are:
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:get :my_cdn_container                            # List all the values
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl"                    # Get the value of the attribute 'X-Ttl'
  hpcloud cdn:containers:get :my_cdn_container "X-Cdn-Uri"                # Get the value of the attribute 'X-Cdn-Uri'
  hpcloud cdn:containers:get :my_cdn_container "X-Ttl" -z region-a.geo-1  # Get the value of the attribute `X-Ttl` for availability zone `regioni-a.geo`
      DESC
      CLI.add_common_options
      define_method "cdn:containers:get" do |name, *attributes|
        cli_command(options) {
          res = ContainerResource.new(Connection.instance.cdn, name)
          name = res.container
          # check to see cdn container exists
          begin
            response = Connection.instance.cdn.head_container(name)
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attributes.empty?
              attributes = allowed_attributes
            end
            attributes.each{ |attribute|
              if allowed_attributes.include?(attribute) == false && response.headers["#{attribute}"].nil?
                @log.error "The value of the attribute '#{attribute}' cannot be retrieved. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
              else
                value = response.headers["#{attribute}"]
                value = "\n" if value.nil?
                @log.display "#{attribute} #{value}"
              end
            }
          rescue Fog::CDN::HP::NotFound => error
            @log.fatal "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
