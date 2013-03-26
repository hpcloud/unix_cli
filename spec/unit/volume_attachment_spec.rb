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
