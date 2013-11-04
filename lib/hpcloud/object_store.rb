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
    class ObjectStore < Resource
      def valid_destination(source)
        return false
      end

      def foreach(&block)
        if @@limit.nil?
          @@limit = Config.new.get_i(:storage_page_length, 10000)
        end
        total = 0
        count = 0
        marker = nil
        begin
          options = { :limit => @@limit, :marker => marker}
          begin
            result = @storage.get_containers(options)
          rescue NoMethodError => e
            result = @storage.directories.each { |container|
              yield ResourceFactory.create(@storage, ':' + container.key)
            }
            return
          end
          total = result.headers['X-Account-Container-Count'].to_i
	  lode = result.body.length
	  count += lode
          result.body.each { |x|
            name = x['name']
            res = ResourceFactory.create(@storage, ':' + name)
            res.size = x['bytes']
            res.count = x['count']
            yield res
            marker = name
          }
          break if lode < @@limit
        end until count >= total
      end

      def is_container?
        true # container of containers
      end
    end
  end
end
