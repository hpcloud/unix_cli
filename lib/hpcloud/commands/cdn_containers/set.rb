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

      desc "cdn:containers:set <name> <attribute> <value>", "Set attributes on a CDN container."
      long_desc <<-DESC
  Set attributes for an existing CDN container by specifying their values. The allowed attributes that can be set are:
  
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900                    # Set the attribute 'X-Ttl' to 900
  hpcloud cdn:containers:set :my_cdn_container "X-Cdn-Uri" "http://my.home.com/cdn"     # Set the attribute 'X-Cdn-Uri' to http://my.home.com/cdn 
  hpcloud cdn:containers:set :my_cdn_container "X-Ttl" 900 -z region-a.geo-1  # Set the attribute `X-Ttl` to 900 for availability zoneregion-a.geo-1`
      DESC
      CLI.add_common_options
      define_method "cdn:containers:set" do |name, attribute, value|
        cli_command(options) {
          begin
            name = name[1..-1] if name.start_with?(":")
            Connection.instance.cdn.head_container(name)
            allowed_attributes = ['X-Ttl', 'X-Cdn-Uri', 'X-Cdn-Enabled', 'X-Log-Retention']
            if attribute && value && allowed_attributes.include?(attribute)
              options = {"#{attribute}" => "#{value}"}
              Connection.instance.cdn.post_container(name, options)
              @log.display "The attribute '#{attribute}' with value '#{value}' was set on CDN container '#{name}'."
            else
              @log.fatal "The attribute '#{attribute}' cannot be set. The allowed attributes are '#{allowed_attributes.join(', ')}'.", :incorrect_usage
            end
          rescue Fog::CDN::HP::NotFound => err
            @log.fatal "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
