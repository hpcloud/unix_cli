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

      desc "cdn:containers:add name [name ...]", "Add containers to the CDN."
      long_desc <<-DESC
  Add existing containers from your storage account to the CDN. Container names can be specified with or without the preceding colon: 'my_container' or ':my_container'. Optionally, you can specify an availability zone.

Examples:
  hpcloud cdn:containers:add :tainer1 :tainer2                    # Add the containers`tainer1` and `tainer2` to the CDN
  hpcloud cdn:containers:add :my_cdn_container -z region-a.geo-1  # Add the container `my_cdn_container` to the CDN in the  availability zone `region-a.geo`
      DESC
      CLI.add_common_options
      define_method "cdn:containers:add" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            res = ContainerResource.new(Connection.instance.storage, name)
            name = res.container
            begin
              if res.container_head()
                response = Connection.instance.cdn.put_container(name)
                @log.display "Added container '#{name}' to the CDN."
              else
                @log.error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
              end
            rescue Fog::Storage::HP::NotFound
              @log.error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
            end
          }
        }
      end
    end
  end
end
