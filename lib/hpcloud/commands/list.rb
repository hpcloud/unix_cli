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
    
      map %w(ls containers containers:list) => 'list'
      map 'ls' => 'list'
    
      desc 'list [container ...]', "List containers or container contents."
      long_desc <<-DESC
  List containers or the contents of the specified containers. Optionally, an availability zone can be passed.

Examples:
  hpcloud list :tain1/sub/ :tain2/sub/          # List the contents of the subdirectory `/sub/` in `tain1` and `tain2`
  hpcloud list :tain1/.*png                     # List the PNG files in `tain1`
  hpcloud list :tainer                          # List all the objects in container `tainer`
  hpcloud list                                  # List all containers
  hpcloud list :my_container -z region-a.geo-1  # List all the objects in container `my_container` for availability zone `region-a.geo-1`

Aliases: ls
      DESC
      method_option :long,
                    :type => :boolean, :aliases => '-l',
                    :desc => 'Long listing.'
      method_option :sync,
                    :type => :boolean,
                    :desc => 'List synchronizations.'
      CLI.add_report_options
      CLI.add_common_options
      def list(*sources)
        cli_command(options) {
          sources = [""] if sources.empty?
          multi = sources.length > 1
          opt = {}
          opt[Columns.option_name] = options[Columns.option_name]
          opt[Tableizer.option_name] = options[Tableizer.option_name]
          if options[:long]
            longlist = true
          else
            if options[:sync]
              longlist = true
            else
              longlist = false
              opt[Tableizer.option_name] = ' ' if opt[Tableizer.option_name].nil?
            end
          end
          sources.each { |name|
            sub_command {
              from = ResourceFactory.create(Connection.instance.storage, name)
              if from.valid_source()
                multi = true unless from.is_container?
                if multi
                  keys = [ "lname" ]
                else
                  keys = [ "sname" ]
                end
                if longlist == true
                  if from.is_object_store?
                    if options[:sync]
                      keys += [ "count", "size", "synckey", "syncto" ]
                    else
                      keys += [ "count", "size" ]
                    end
                  else
                    keys += [ "size", "type", "etag", "modified" ]
                  end
                end
                tableizer = Tableizer.new(opt, keys)
                from.foreach { |file|
                  if options[:sync]
                    file.container_head(true)
                  end
                  tableizer.add(file.to_hash)
                }
                tableizer.print


                if tableizer.found == false
                  if from.is_object_store?
                    @log.error "Cannot find any containers, use `#{selfname} containers:add <name>` to create one.", :not_found
                  elsif from.isDirectory() == false
                    @log.error "Cannot find resource named '#{name}'.", :not_found
                  end
                end
              else
                @log.error from.cstatus
              end
            }
          }
        }
      end
    end
  end
end
