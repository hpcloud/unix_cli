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

      map 'containers:get' => 'metadata'

      desc "metadata <name> [attribute...]", "Get the metadata value of a container or object."
      long_desc <<-DESC
  Get the various metadata values for an object or container.

Examples:
  hpcloud metadata :my_container              # List all the attributes
  hpcloud metadata :my_container X-Cdn-Uri    # Get the value of the attribute 'X-Cdn-Uri'
  hpcloud metadata :my_container/dir/file.txt # List all the attributes for the object
      DESC
      CLI.add_common_options
      define_method "metadata" do |name, *attributes|
        cli_command(options) {
          resource = ResourceFactory.create(Connection.instance.storage, name)
          unless resource.head
            @log.fatal resource.cstatus
          end
          if attributes.empty?
            hsh = resource.printable_headers
            keyo = hsh.keys.sort
          else
            hsh = resource.headers
            keyo = attributes
          end
          keyo.each{ |k|
            v = hsh[k]
            v = "\n" if v.nil?
            @log.display "#{k} #{v}"
          }
        }
      end
    end
  end
end
