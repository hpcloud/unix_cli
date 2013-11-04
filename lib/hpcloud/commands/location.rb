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
    
      map 'loc' => 'location'
    
      desc 'location <object/container> ...', 'Display the URIs for the specified resources.'
      long_desc <<-DESC
  Display the URI of the specified object or container. Optionally, you can specify an availability zone.

Examples:
  hpcloud location :my_container/file.txt  # Display the URI for the file `file.txt` that resides in container `my_container`
  hpcloud location :my_container  #  Display the URI for all objects in container `my_container`
  hpcloud location :my_container/file.txt :my_container/other.txt # Display the URIs for the objects `file.txt` and `other.txt` that reside in container `my_container`
  hpcloud location :my_container/file.txt -z region-a.geo-1  # Display the URI for the file `file.txt` that resides in container `my_container` in availability zone `region-a.geo-1`

Aliases: loc
      DESC
      CLI.add_common_options
      def location(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.head
              @log.display resource.public_url
            else
              @log.error resource.cstatus
            end
          }
        }
      end
    end
  end
end
