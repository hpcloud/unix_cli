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

describe "VolumeAttachment keys" do
  context "when we get list server keys" do
    it "should have expected values" do
      keys = HP::Cloud::VolumeAttachment.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("server")
      keys[3].should eql("device")
      keys.length.should eql(4)
    end
  end
end

describe "VolumeAttachment methods" do
  before(:all) do
      @fog_hash = VolumeAttachmentHelper.createHash("2")
  end

  context "when we convert constructor" do
    it "get all the expected values" do
      va = HP::Cloud::VolumeAttachment.new(@fog_hash)

      va.device.should eql("/dev/vd2")
      va.serverId.should eql("12")
      va.id.should eql("2")
      va.volumeId.should eql("22")
      va.name.should eql("vol22")
      va.server.should eql("srv12")
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::VolumeAttachment.new(@fog_hash).to_hash()

      hash["device"].should eql("/dev/vd2")
      hash["serverId"].should eql("12")
      hash["id"].should eql("2")
      hash["volumeId"].should eql("22")
      hash["name"].should eql("vol22")
      hash["server"].should eql("srv12")
    end
  end
end
