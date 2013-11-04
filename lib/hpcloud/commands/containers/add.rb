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
    
      desc "containers:add name [name ...]", "Add a container."
      long_desc <<-DESC
  Add a new container to your storage account. You may creeate multiple containers by specifying more than one container name on the command line.  You can specify the ontainer name  with or without the preceding colon: 'my_container' or ':my_container'. Optionally, you can specify an availability zone.

Examples:
  hpcloud containers:add :my_container                    # Create a new container called 'my_container'
  hpcloud containers:add :con :tainer                     # Create two new containers called 'con' and 'tainer'
  hpcloud containers:add :my_container -z region-a.geo-1  # Create the container `my_container` for the availability zone `region-a.geo-1`
      DESC
      method_option :force, :default => false,
                    :type => :boolean, :aliases => '-f',
                    :desc => "Don't prompt if container name is not a valid virtual host."
      CLI.add_common_options
      define_method "containers:add" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            sub_command("adding container") {
              res = ContainerResource.new(Connection.instance.storage, name)
              name = res.container
              if res.container_head()
                @log.fatal "Container '#{name}' already exists.", :conflicted
              else
                if acceptable_name?(res, options)
                  Connection.instance.storage.directories.create(:key => name)
                  @log.display "Created container '#{name}'."
                end
              end
            }
          }
        }
      end
      
      private
      
      def acceptable_name?(res, options)
        res.valid_virtualhost? or options[:force] or yes?('Specified container name is not a valid virtualhost, continue anyway? [y/n]')
      end
    
    end
  end
end
