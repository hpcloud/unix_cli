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

      desc "volumes:add <name> [size]", "Add a volume."
      long_desc <<-DESC
  Add a new volume to your compute account with the specified name and size.  Optionally, you can specify a description, metadata or availability zone.  If you do not specify a size, it is taken from the specified snapshot or image.  If no image or snapshot is specified, the size defaults to 1 gigabyte.

Examples:
  hpcloud volumes:add my_volume 10 --zone az3    # Create a new volume named 'my_volume' of size 10 in zone az3
  hpcloud volumes:add my_volume -s 'snappy'      # Create a new volume named 'my_volume' based on the snapshot 'snappy'
  hpcloud volumes:add my_volume -i 53e78869      # Create a new bootable volume named 'my_volume' based on the image '53e78869'
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the volume.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the metadata.'
      method_option :snapshot,
                    :type => :string, :aliases => '-s',
                    :desc => 'Create a volume from the specified snapshot.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Create a volume from the specified image.'
      method_option :zone,
                    :type => :string,
                    :desc => 'Create a volume in the specified zone.'
      CLI.add_common_options
      define_method "volumes:add" do |name, *volume_size|
        cli_command(options) {
          if Volumes.new.get(name).is_valid? == true
            @log.fatal "Volume with the name '#{name}' already exists"
          end
          vol = HP::Cloud::VolumeHelper.new(Connection.instance)
          vol.name = name
          vol.size = volume_size.first
          unless options[:snapshot].nil?
            snapshot = HP::Cloud::Snapshots.new.get(options[:snapshot])
            if snapshot.is_valid?
              vol.snapshot_id = snapshot.id.to_s
              vol.size = snapshot.size.to_s if vol.size.nil?
            else
              @log.fatal snapshot.cstatus
            end
          end
          unless options[:image].nil?
            image = HP::Cloud::Images.new.get(options[:image])
            if image.is_valid?
              vol.imageref = image.id.to_s
            else
              @log.fatal image.cstatus
            end
          end
          vol.size = 1 if vol.size.nil?
          vol.description = options[:description]
          vol.availability_zone = options[:zone]
          if vol.save == true
            @log.display "Created volume '#{name}' with id '#{vol.id}'."
          else
            @log.fatal vol.cstatus
          end
        }
      end
    end
  end
end
