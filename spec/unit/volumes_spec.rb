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

describe "Volumes getter" do
  def mock_volume(name)
    fog_volume = double(name)
    @id = 1 if @id.nil?
    fog_volume.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_volume.stub(:name).and_return(name)
    fog_volume.stub(:size).and_return(0)
    fog_volume.stub(:type).and_return(nil)
    fog_volume.stub(:created_at).and_return(Date.new(2011, 10, 31))
    fog_volume.stub(:status).and_return("available")
    fog_volume.stub(:description).and_return("My cool disk")
    fog_volume.stub(:attachments).and_return([])
    fog_volume.stub(:availability_zone).and_return("az4")
    return fog_volume
  end

  before(:each) do
    @volumes = [ mock_volume("vol1"), mock_volume("vol2"), mock_volume("vol3"), mock_volume("vol3") ]
    @block = double("block")
    @block.stub(:volumes).and_return(@volumes)


    @compute = double("compute")
    @compute.stub(:servers).and_return([])
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    @connection.stub(:block).and_return(@block)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      volumes = Volumes.new.get()

      volumes[0].name.should eql("vol1")
      volumes[1].name.should eql("vol2")
      volumes[2].name.should eql("vol3")
      volumes[3].name.should eql("vol3")
      volumes.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      volumes = Volumes.new.get(["3"])

      volumes[0].name.should eql("vol3")
      volumes[0].id.to_s.should eql("3")
      volumes.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      volumes = Volumes.new.get(["vol2"])

      volumes[0].name.should eql("vol2")
      volumes.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      volumes = Volumes.new.get(["1", "vol2"])

      volumes[0].name.should eql("vol1")
      volumes[1].name.should eql("vol2")
      volumes.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      volumes = Volumes.new.get(["vol3"])

      volumes[0].name.should eql("vol3")
      volumes[1].name.should eql("vol3")
      volumes.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      volumes = Volumes.new.get(["vol3"], false)

      volumes[0].is_valid?.should be_false
      volumes[0].cstatus.error_code.should eq(:general_error)
      volumes[0].cstatus.message.should eq("More than one volume matches 'vol3', use the id instead of name.")
      volumes.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      volumes = Volumes.new.get(["bogus"])

      volumes[0].is_valid?.should be_false
      volumes[0].cstatus.error_code.should eq(:not_found)
      volumes[0].cstatus.message.should eq("Cannot find a volume matching 'bogus'.")
      volumes.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Volumes.new.empty?.should be_false
    end
  end
end
