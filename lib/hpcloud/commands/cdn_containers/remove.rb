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

      map %w(cdn:containers:rm cdn:containers:delete cdn:containers:del) => 'cdn:containers:remove'

      desc "cdn:containers:remove name [name ...]", "Remove containers from the CDN."
      long_desc <<-DESC
  Remove containers from the CDN. Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:remove :tainer1 :tainer2                    # Delete the containers `:tainer1` and `:tainer2` from the CDN
  hpcloud cdn:containers:remove :my_cdn_container -z region-a.geo-1  # Delete the container `my_cdn_container for the availability zone `region-a.geo-1` from the CDN

Aliases: cdn:containers:rm, cdn:containers:delete, cdn:containers:del
      DESC
      CLI.add_common_options
      define_method "cdn:containers:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            begin
              name = name[1..-1] if name.start_with?(":")
              Connection.instance.cdn.delete_container(name)
              @log.display "Removed container '#{name}' from the CDN."
            rescue Excon::Errors::NotFound, Fog::CDN::HP::NotFound
              @log.error "You don't have a container named '#{name}' on the CDN.", :not_found
            end
          }
        }
      end
    end
  end
end
