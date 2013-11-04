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
    
      map 'mv' => 'move'
    
      desc 'move <source ...> <destination>', 'Move objects inside or between containers.'
      long_desc <<-DESC
  Move objects to a new location inside a container or between containers. The source file is removed after a successful transfer. If you specify more than one source, the destination must be a container, or a directory ending in `/`.  Optionally, you can specify an availability zone.  For copying files to and from your local filesystem see `copy`.

Examples:
  hpcloud move :my_container/file.txt :my_container/old/backup.txt # Move file `file.txt` to new name and location `old/backup.txt` in container `my_container`
  hpcloud move :my_container/file.txt :other_container/file.txt #  Move file `file.txt` from container `my_container` to container `other_container`
  hpcloud move :tain/f1.txt :tain/f2.txt :othertain/directory/  # Move files `f1.txt` and f2.txt` from container `tain` to directory `/directory` in container `othertain`
  hpcloud move :my_container/file.txt :my_container/old/backup.txt -z region-a.geo-1  # Move file `file.txt` to new name and location `old/backup.txt` in container `my_container` for availability zone `region-a.geo-1`

Aliases: mv
      DESC
      CLI.add_common_options
      def move(source, *destination)
        cli_command(options) {
          last = destination.pop
          if last.nil?
            @log.fatal "To move you must specify a source and a destination", :incorrect_usage
          end
          source = [source] + destination
          destination = last
          to = ResourceFactory.create_any(Connection.instance.storage, destination)
          if source.length > 1 && to.isDirectory() == false
            @log.fatal("The destination '#{destination}' for multiple files must be a directory or container")
          end
          source.each { |name|
            from = ResourceFactory.create_any(Connection.instance.storage, name)
            if from.isLocal()
              @log.error "Move is limited to remote objects. Please use '#{selfname} copy' instead.", :incorrect_usage
              next
            end
            if to.copy(from)
              if from.remove(false)
                @log.display "Moved #{from.fname} => #{to.fname}"
              else
                @log.error from.cstatus
              end
            else
              @log.error to.cstatus
            end
          }
        }
      end
    end
  end
end
