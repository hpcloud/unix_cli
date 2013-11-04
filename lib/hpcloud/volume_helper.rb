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
    class VolumeHelper < BaseHelper
      @@serverous = nil
      attr_accessor :id, :name, :size, :type, :created, :status, :description, :servers, :snapshot_id, :imageref, :availability_zone
      attr_accessor :meta
    
      def self.get_keys()
        return [ "id", "name", "size", "type", "created", "status", "description", "servers", "availability_zone" ]
      end

      def initialize(connection, foggy = nil)
        super(connection, foggy)
        if foggy.nil?
          return
        end
        @id = foggy.id
        @name = foggy.name
        @size = foggy.size
        @type = foggy.type
        @created = foggy.created_at
        @status = foggy.status
        @description = foggy.description
        @availability_zone = foggy.availability_zone
        @servers = ''
        @@serverous = Servers.new if @@serverous.nil?
        foggy.attachments.each { |x|
          srv = @@serverous.get(x["server_id"].to_s)
          if srv.is_valid? == false
            next
          end
          if @servers.length > 0
            @servers += ','
          end
          @servers += srv.name
        }
      end

      def save
        return false if is_valid? == false
        if @fog.nil?
          hsh = {:name => @name,
             :description => @description,
             :size => @size}
          hsh[:snapshot_id] = @snapshot_id unless @snapshot_id.nil?
          hsh[:image_id] = @imageref unless @imageref.nil?
          hsh[:availability_zone] = @availability_zone unless @availability_zone.nil?
          volume = @connection.block.volumes.create(hsh)
          if volume.nil?
            set_error("Error creating volume '#{@name}'")
            return false
          end
          @id = volume.id
          @fog = volume
          return true
        else
          raise "Update not implemented"
        end
      end

      def attach(server, device)
        begin
          @fog.attach(server.id, device)
        rescue Exception => e
          set_error("Error attaching '#{name}' on server '#{server.name}' to device '#{device}'.")
          return false
        end
        return true
      end

      def detach()
        begin
          @fog.detach
        rescue Exception => e
          set_error("Error detaching '#{name}' from '#{@servers}'.")
          return false
        end
        return true
      end

      def self.clear_cache
        @@serverous = nil
      end

      def map_device(device)
        begin
          return "/dev/vda" if device == "0"
          i = device.to_i
          return device if i < 1 || i > 26
          i = i +  96
          return "/dev/vd" + i.chr
        rescue Exception => e
        end
        return device
      end
    end
  end
end
