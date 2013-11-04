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

      desc "images:add <name> <server_name>", "Add an image from an existing server."
      long_desc <<-DESC
  Add a new image from an existing server to your compute account. Optionally, you may specify metadata or an availability zone.

Examples:
  hpcloud images:add my_image my_server                           # Create the new image 'my_image' from the existing server named 'my_server'
  hpcloud images:add my_image 701be39b -m this=that              # Create the new image 'my_image' from the existing server '701be39b' with metadata
      DESC
      CLI.add_common_options
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      define_method "images:add" do |name, server_name|
        cli_command(options) {
          img = HP::Cloud::ImageHelper.new()
          img.name = name
          img.set_server(server_name)
          img.meta.set_metadata(options[:metadata])
          if img.save == true
            @log.display "Created image '#{name}' with id '#{img.id}'."
          else
            @log.fatal img.cstatus
          end
        }
      end

    end
  end
end
