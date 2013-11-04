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

      map %w(rm delete destroy del) => 'remove'

      desc 'remove object_or_container [object_or_container ...]', 'Remove objects or containers.'
      long_desc <<-DESC
  Remove objects or containers. Optionally, you can specify an availability zone.
        
Examples:
  hpcloud remove :tainer/my.txt :tainer/other.txt # Delete objects 'my.txt' and 'other.txt' from container `tainer`
  hpcloud remove :my_container                    # Delete container 'my_container'
  hpcloud remove --after 7200 :my_container/current.log  # Delete object 'my_container/current.log' after 2 hours
  hpcloud remove --at 1366119838 :my_container/current.log  # Delete object 'my_container/current.log' in the morning of 4/16/2013
  hpcloud remove :my_container -z region-a.geo-1  # Delete container 'my_container' in availability zone `region-a.geo-1`

Aliases: rm, delete, destroy, del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Do not confirm removal; remove non-empty containers.'
      method_option :at,
                    :type => :string,
                    :desc => 'Delete the object at the specified UNIX epoch time.'
      method_option :after,
                    :type => :string,
                    :desc => 'Delete the object after the specified number of seconds.'
      CLI.add_common_options
      def remove(name, *names)
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.remove(options.force, options[:at], options[:after])
              if options[:at].nil?
                if options[:after].nil?
                  @log.display "Removed '#{name}'."
                else
                  @log.display "Removing '#{name}' after #{options[:after]} seconds."
                end
              else
                @log.display "Removing '#{name}' at #{options[:at]} seconds of the epoch."
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

