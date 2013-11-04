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

      map 'cdn:containers:loc' => 'cdn:containers:location'

      desc "cdn:containers:location <name>", "Get the location of a container on the CDN."
      long_desc <<-DESC
  Get the location of an existing container on the CDN. Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:location :my_cdn_container                     # Get the location of the container 'my_cdn_container'
  hpcloud cdn:containers:location :my_cdn_container -z region-a.geo-1   # Get the location of the container `my_cdn_container` for availability zone `region-a.geo-1`

Aliases: cdn:containers:loc
      DESC
      method_option :ssl, :default => false,
                    :type => :boolean, :aliases => '-s',
                    :desc => 'Print the SSL version of the URL.'
      CLI.add_common_options
      define_method "cdn:containers:location" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.container_head
              if options.ssl
                @log.display resource.cdn_public_ssl_url
              else
                @log.display resource.cdn_public_url
              end
            else
              @log.error resource.cstatus
            end
          }
        }
      end
    end
  end
end
