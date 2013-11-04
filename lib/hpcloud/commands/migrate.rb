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

      desc 'migrate <source_account> <source> [source ...] <destination>', "Migrate files from a provider described by the source account."
      long_desc <<-DESC
  Migrates files from the designated provider to the HP Cloud destination. This command works similarly to `copy` except the first argument is the source account (for example, `AWS`).  The source objects may be containers, objects, or regular expressions.

Examples:
  hpcloud migrate aws :aws_tainer :hp_tainer # Migrate objects from the AWS `:aws_tainer` container to the `:hp_tainer` container
  hpcloud migrate rackspace :rackspace1 :rackspace2 :hp_tainer # Migrate objects from the two containers in the Rackspace account to the `:hp_tainer` container

      DESC
      method_option :mime,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the MIME type of the remote object.'
      CLI.add_common_options
      def migrate(source_account, source, *destination)
        cli_command(options) {
          last = destination.pop
          source = [source] + destination
          destination = last
          to = ResourceFactory.create_any(Connection.instance.storage, destination)
          if source.length > 1 && to.isDirectory() == false
            @log.fatal("The destination '#{destination}' for multiple files, must be a directory or container")
          end
          source.each { |name|
            from = ResourceFactory.create_any(Connection.instance.storage(source_account), name)
            from.set_mime_type(options[:mime])
            if to.copy(from)
              @log.display "Migrated #{from.fname} => #{to.fname}"
            else
              @log.fatal to.cstatus
            end
          }
        }
      end
    end
  end
end
