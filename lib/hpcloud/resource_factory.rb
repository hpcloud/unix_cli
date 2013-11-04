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

require 'hpcloud/resource.rb'
require 'hpcloud/container_resource.rb'
require 'hpcloud/local_resource.rb'
require 'hpcloud/remote_resource.rb'
require 'hpcloud/shared_resource.rb'
require 'hpcloud/object_store.rb'

module HP
  module Cloud
    class ResourceFactory
    
      REMOTE_TYPES = [:container,
                      :container_directory,
                      :object,
                      :object_store,
                      :shared_directory,
                      :shared_resource]
      LOCAL_TYPES = [:directory, :file]

      def self.create(storage, fname)
        unless (fname.start_with?('http://') || fname.start_with?('https://'))
          if fname.length > 0
            unless fname.start_with?(':')
              unless fname.start_with?('/')
                unless fname.start_with?('.')
                  fname = ':' + fname
                end
              end
            end
          end
        end
        return ResourceFactory.create_any(storage, fname)
      end

      def self.create_any(storage, fname)
        ftype = detect_type(fname)
        case ftype
        when :directory, :file
          return LocalResource.new(storage, fname)
        when :object_store
          return ObjectStore.new(storage, fname)
        when :shared_resource, :shared_directory
          return SharedResource.new(storage, fname)
        when :container
          return ContainerResource.new(storage, fname)
        end
        return RemoteResource.new(storage, fname)
      end

      def self.detect_type(resource)
        if resource.empty?
          return :object_store
        end
        if resource[0,1] == ':'
          if resource[-1,1] == '/'
            :container_directory
          elsif resource.index('/')
            :object
          else
            :container
          end
        else
          if (resource.start_with?('http://') ||
              resource.start_with?('https://'))
            if resource[-1,1] == '/'
              :shared_directory
            else
              :shared_resource
            end
          elsif resource[-1,1] == '/'
            :directory
          elsif File.directory?(resource)
            :directory
          else
            :file
          end
        end
      end

      def self.is_local?(ftype)
        return ResourceFactory::LOCAL_TYPES.include?(ftype)
      end

      def self.is_remote?(ftype)
        return ResourceFactory::REMOTE_TYPES.include?(ftype)
      end
    end
  end
end
