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

require 'hpcloud/exceptions/general'
require 'hpcloud/exceptions/not_found'

module HP
  module Cloud
    class FogCollection
      attr_reader :name, :items
    
      def initialize(name, article='a')
        @name = name
        @article = article
        @connection = Connection.instance
      end

      def matches(arg, item)
        return ((arg == item.id.to_s) || (arg == item.name.to_s))
      end

      def filter(arguments = [], multimatch=true)
        if @ray.nil?
          @ray = []
          @items.each { |x| @ray << create(x) }
        end
        if (arguments.empty?)
          return @ray
        end
        retray = []
        arguments.each { |arg|
          found = []
          @ray.each { |item|
            if matches(arg, item)
              if (multimatch == true)
                found << item
              else
                if found.length == 0
                  found << item
                else
                  if found[0].respond_to?(:set_error)
                    found[0].set_error("More than one #{@name} matches '#{arg}', use the id instead of name.")
                  else
                    raise HP::Cloud::Exceptions::General.new("More than one #{@name} matches '#{arg}', use the id instead of name.")
                  end
                end
              end
            end
          }
          if found.length == 0
            item = create()
            if item.nil?
              raise HP::Cloud::Exceptions::NotFound.new("Cannot find #{@article} #{@name} matching '#{arg}'.")
            end
            if item.respond_to?(:name)
              item.name = arg
            end
            item.set_error("Cannot find #{@article} #{@name} matching '#{arg}'.", :not_found)
            retray << item
          else
            retray += found
          end
        }
        return retray
      end

      def get(arguments = [], multimatch=true)
        if arguments.kind_of?(Array)
          return filter(arguments, multimatch)
        end
        return filter([arguments], false).first
      end

      def get_array(arguments = [])
        ray = []
        get(arguments, true).each { |x|
          if x.respond_to?(:to_hash)
            hsh = x.to_hash()
          else
            hsh = Hash[x.attributes.map{ |k, v| [k.to_s, v] }]
          end
          ray << hsh unless hsh.nil?
        }
        return ray
      end

      def empty?
        return true if @items.nil?
        return @items.empty?
      end

      def create(item = nil)
        return item
      end

      def unique(name)
        begin
          get(name)
          raise HP::Cloud::Exceptions::General.new("A #{@name} with the name '#{name}' already exists")
        rescue HP::Cloud::Exceptions::NotFound => e
        end
        return nil
      end
    end
  end
end
