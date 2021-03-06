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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Volume keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::VolumeHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("size")
      keys[3].should eql("type")
      keys[4].should eql("created")
      keys[5].should eql("status")
      keys[6].should eql("description")
      keys[7].should eql("servers")
      keys[8].should eql("availability_zone")
      keys.length.should eql(9)
    end
  end
end

describe "Volume methods" do
  before(:each) do
    VolumeHelper.clear_cache
    @fog_volume = double("fog_volume")
    @fog_volume.stub(:id).and_return(1)
    @fog_volume.stub(:name).and_return("MyDisk")
    @fog_volume.stub(:size).and_return(0)
    @fog_volume.stub(:type).and_return(nil)
    @fog_volume.stub(:created_at).and_return(Date.new(2011, 10, 31))
    @fog_volume.stub(:status).and_return("available")
    @fog_volume.stub(:description).and_return("My cool disk")
    @fog_volume.stub(:attachments).and_return([{"serverId"=>123},{"serverId"=>345}])
    @fog_volume.stub(:availability_zone).and_return("az3")
    @sv1 = double("sv1")
    @sv1.stub(:name).and_return("srv1")
    @sv1.stub(:is_valid?).and_return(true)
    @sv2 = double("sv2")
    @sv2.stub(:name).and_return("srv2")
    @sv2.stub(:is_valid?).and_return(true)
   
    @servers = double("servers")
    @servers.stub(:get).and_return(@sv1, @sv2)
    HP::Cloud::Servers.stub(:new).and_return(@servers)
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)

      disk.id.should eql(1)
      disk.name.should eql("MyDisk")
      disk.size.should eql(0)
      disk.type.should be_nil
      disk.created.should eql(Date.new(2011, 10, 31))
      disk.status.should eql("available")
      disk.description.should eq("My cool disk")
      disk.servers.should eq('srv1,srv2')
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::VolumeHelper.new(double("connection"))

      disk.id.should be_nil
      disk.name.should be_nil
      disk.size.should be_nil
      disk.type.should be_nil
      disk.created.should be_nil
      disk.status.should be_nil
      disk.description.should be_nil
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyDisk")
      hash["size"].should eql(0)
      hash["type"].should be_nil
      hash["created"].should eql(Date.new(2011, 10, 31))
      hash["status"].should eql("available")
      hash["description"].should eq("My cool disk")
      hash["servers"].should eq('srv1,srv2')
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_volume = double("new_volume")
      @new_volume.stub(:id).and_return(909)
      @volumes = double("volumes")
      @volumes.stub(:create).and_return(@new_volume)
      @block = double("block")
      @block.stub(:volumes).and_return(@volumes)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      vol = HP::Cloud::VolumeHelper.new(@connection)
      vol.name = 'lion'
      vol.size = 100
      vol.description = 'mt lion'

      vol.save.should be_true

      vol.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @volumes = double("volumes")
      @volumes.stub(:create).and_return(nil)
      @block = double("block")
      @block.stub(:volumes).and_return(@volumes)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      vol = HP::Cloud::VolumeHelper.new(@connection)
      vol.name = 'lion'
      vol.size = 100
      vol.description = 'mt lion'

      vol.save.should be_false

      vol.id.should be_nil
      vol.cstatus.message.should eq("Error creating volume 'lion'")
      vol.cstatus.error_code.should eq(:general_error)
    end
  end

  context "when attach succeeds" do
    it "it returns true" do
      vol = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)
      @device = "/dev/asdf"
      @server = double("server")
      @server.stub(:id).and_return(2)
      @server.stub(:name).and_return("zoidberg")
      @fog_volume.should_receive(:attach).with(@server.id, @device)

      vol.attach(@server, @device).should be_true
    end
  end

  context "when attach fails" do
    it "it returns false and sets error" do
      vol = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)
      @device = "/dev/asdf"
      @server = double("server")
      @server.stub(:id).and_return(2)
      @server.stub(:name).and_return("zoidberg")
      @fog_volume.should_receive(:attach).with(@server.id, @device).and_raise(Exception.new)

      vol.attach(@server, @device).should be_false

      vol.cstatus.message.should eq("Error attaching 'MyDisk' on server 'zoidberg' to device '/dev/asdf'.")
      vol.cstatus.error_code.should eq(:general_error)
    end
  end

  context "when detach succeeds" do
    it "it returns true" do
      vol = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)
      @fog_volume.should_receive(:detach).with()

      vol.detach().should be_true
    end
  end

  context "when detach fails" do
    it "it returns false and sets error" do
      vol = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)
      @fog_volume.should_receive(:detach).with().and_raise(Exception.new)

      vol.detach().should be_false

      vol.cstatus.message.should eq("Error detaching 'MyDisk' from 'srv1,srv2'.")
      vol.cstatus.error_code.should eq(:general_error)
    end
  end

  context "map_device" do
    it "maps" do
      vol = HP::Cloud::VolumeHelper.new(double("connection"), @fog_volume)

      vol.map_device("-1").should eq("-1")
      vol.map_device("0").should eq("/dev/vda")
      vol.map_device("1").should eq("/dev/vda")
      vol.map_device("2").should eq("/dev/vdb")
      vol.map_device("3").should eq("/dev/vdc")
      vol.map_device("4").should eq("/dev/vdd")
      vol.map_device("5").should eq("/dev/vde")
      vol.map_device("6").should eq("/dev/vdf")
      vol.map_device("7").should eq("/dev/vdg")
      vol.map_device("8").should eq("/dev/vdh")
      vol.map_device("9").should eq("/dev/vdi")
      vol.map_device("10").should eq("/dev/vdj")
      vol.map_device("11").should eq("/dev/vdk")
      vol.map_device("12").should eq("/dev/vdl")
      vol.map_device("13").should eq("/dev/vdm")
      vol.map_device("14").should eq("/dev/vdn")
      vol.map_device("15").should eq("/dev/vdo")
      vol.map_device("16").should eq("/dev/vdp")
      vol.map_device("17").should eq("/dev/vdq")
      vol.map_device("18").should eq("/dev/vdr")
      vol.map_device("19").should eq("/dev/vds")
      vol.map_device("20").should eq("/dev/vdt")
      vol.map_device("21").should eq("/dev/vdu")
      vol.map_device("22").should eq("/dev/vdv")
      vol.map_device("23").should eq("/dev/vdw")
      vol.map_device("24").should eq("/dev/vdx")
      vol.map_device("25").should eq("/dev/vdy")
      vol.map_device("26").should eq("/dev/vdz")
      vol.map_device("27").should eq("27")
      vol.map_device("/dev/vda").should eq("/dev/vda")
      vol.map_device("/dev/vdb").should eq("/dev/vdb")
      vol.map_device("/dev/vdc").should eq("/dev/vdc")
    end
  end
end
