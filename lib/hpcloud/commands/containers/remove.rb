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
    
      map %w(containers:rm containers:delete containers:del) => 'containers:remove'
    
      desc "containers:remove name [name ...]", "Remove a containers."
      long_desc <<-DESC
  Remove one or more containers. By default this command removes a container if it is empty, but you may use the `--force` flag to delete non-empty containers.  Be careful with this flag or you could have a really bad day.

Examples:
  hpcloud containers:remove :my_container                     # Delete 'my_container' (if empty)
  hpcloud containers:remove :tainer1 :tainer2                 # Delete 'tainer1' and 'tainer2' (if empty)
  hpcloud containers:remove :my_container --force             # Delete `my container` (regardless of contents)
  hpcloud containers:remove :my_container -z region-a.geo-1   # Delete the container `my_container` for availability zone 'region-a.geo-1`

Aliases: containers:rm, containers:delete, containers:del
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => 'Force removal of non-empty containers.'
      CLI.add_common_options
      define_method "containers:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            resource = ResourceFactory.create(Connection.instance.storage, name)
            if resource.is_container?
              if resource.remove(options.force)
                @log.display "Removed container '#{name}'."
              else
                @log.error resource.cstatus
              end
            else
              @log.error "The specified object is not a container: #{name}", :incorrect_usage
            end
          }
        }
      end
    end
  end
end
