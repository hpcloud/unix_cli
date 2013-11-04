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

require 'hpcloud/commands/acl/grant'
require 'hpcloud/commands/acl/revoke'

module HP
  module Cloud
    class CLI < Thor

      desc 'acl <object/container>', "View the ACL for an object or container."
      long_desc <<-DESC
  View the access control list (ACL) for a container or object. Optionally, you can specify an availability zone.

Examples:
  hpcloud acl :my_container/my_file.txt         # Display the ACL for the object 'my_file.txt'
  hpcloud acl :my_container                     # Display the ACL for the container 'my_container'
  hpcloud acl :my_container -z region-a.geo-1  # Display the ACL for the container 'my_container' for availability zone `region-a.geo-1`
      DESC
      CLI.add_report_options
      CLI.add_common_options
      def acl(name, *names)
        cli_command(options) {
          names = [name] + names

          ray = []
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.container_head
              ray << resource.to_hash()
            else
              @log.error resource.cstatus
            end
          }
          keys =  [ "public", "readers", "writers", "public_url"]
          if ray.empty?
            @log.display "There are no resources that match the provided arguments"
          else
            Tableizer.new(options, keys, ray).print
          end
        }
      end
    end
  end
end
