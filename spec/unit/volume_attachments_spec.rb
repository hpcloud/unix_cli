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

describe "VolumeAttachments getter" do

  before(:each) do
    va1 = VolumeAttachmentHelper.createHash("1")
    va2 = VolumeAttachmentHelper.createHash("2")
    va3 = VolumeAttachmentHelper.createHash("3")
    va4 = VolumeAttachmentHelper.createHash("4")
    @vas = [ va1, va2, va3, va4 ]
    @body = {}
    @body["volumeAttachments"] = @vas
    @rsp = double("rsp")
    @rsp.stub(:body).and_return(@body)

    @compute = double("compute")
    @compute.stub(:list_server_volumes).and_return(@rsp)
    @compute.stub(:servers).and_return([])

    @block = double("block")
    @volumes = []
    @block.stub(:volumes).and_return(@volumes)

    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    @connection.stub(:block).and_return(@block)
    Connection.stub(:instance).and_return(@connection)

    @server = double("server")
    @server.stub(:id).and_return(11)
    @server.stub(:name).and_return("oberhofer")
  end

  context "when we get with no arguments" do
    it "should return them all" do
      vas = VolumeAttachments.new(@server).get()

      vas[0].name.should eql("vol21")
      vas[1].name.should eql("vol22")
      vas[2].name.should eql("vol23")
      vas[3].name.should eql("vol24")
      vas.length.should eql(4)
    end
  end

  context "when no response" do
    it "should get exception" do
      Connection.instance.compute.stub(:list_server_volumes).and_return(nil)
      expect {
        VolumeAttachments.new(@server)
      }.should raise_error(Exception) { |error|
        error.to_s.should eq("List server volumes should include response body with volumeAttachments")
      }
    end
  end

  context "when no response" do
    it "should get exception" do
      @rsp.stub(:body).and_return(nil)
      expect {
        VolumeAttachments.new(@server)
      }.should raise_error(Exception) { |error|
        error.to_s.should eq("List server volumes should include response body with volumeAttachments")
      }
    end
  end

  context "when no response" do
    it "should get exception" do
      @body["volumeAttachments"] = nil
      expect {
        VolumeAttachments.new(@server)
      }.should raise_error(Exception) { |error|
        error.to_s.should eq("List server volumes should include response body with volumeAttachments")
      }
    end
  end

  context "when raises exception" do
    it "should get exception" do
      Connection.instance.compute.stub(:list_server_volumes).and_raise(Exception.new)
      expect {
        VolumeAttachments.new(@server)
      }.should raise_error(Exception) { |error|
        error.to_s.should eq("List server volumes call failed")
      }
    end
  end

  context "when check empty" do
    it "should return false" do
      VolumeAttachments.new(@server).empty?.should be_false
    end
  end 
end
