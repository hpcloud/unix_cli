require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Image class" do

  before(:each) do
    @fog_image = double("image")
    @fog_image.stub(:id).and_return(1)
    @fog_image.stub(:name).and_return("Slackware")
    @fog_image.stub(:created_at).and_return("yesterday")
    @fog_image.stub(:status).and_return("g2g")
    @graupel = double("graupel")
    @graupel.stub(:key).and_return("graupel")
    @graupel.stub(:value).and_return("balls")
    @dendrite = double("dendrite")
    @dendrite.stub(:key).and_return("dendrite")
    @dendrite.stub(:value).and_return("flakes")
    @fog_metadata = double("fog_metadata")
    @fog_metadata.stub(:map).and_yield(@graupel).and_yield(@dendrite)
    @fog_metadata.stub(:get).and_return(@graupel)
    @fog_image.stub(:metadata).and_return(@fog_metadata)

    @images = double("images")
    @images.stub(:get).and_return(double("new_image"))

    @server = double("server")
    @server.stub(:id).and_return(222)
    @server.stub(:name).and_return("Hal")
    @server.stub(:flavor_id).and_return(201)
    @server.stub(:image_id).and_return(101)
    @server.stub(:public_ip_address).and_return("172.0.0.1")
    @server.stub(:private_ip_address).and_return("10.0.0.1")
    @server.stub(:key_name).and_return("key")
    @server.stub(:security_groups).and_return(nil)
    @server.stub(:created_at).and_return(nil)
    @server.stub(:state).and_return(nil)
    @server.stub(:metadata).and_return(nil)
    @server.stub(:is_valid?).and_return(true)

    @servers = double("servers")
    @servers.stub(:get).and_return(@server)
    HP::Cloud::Servers.stub(:new).and_return(@servers)
  end

  context "when we get keys" do
    it "should have expected values" do
      keys = HP::Cloud::ImageHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("created_at")
      keys[3].should eql("status")
      keys.length.should eql(4)
    end
  end

  context "when we construct" do
    it "should have expected values" do
      img = HP::Cloud::ImageHelper.new(@fog_image)

      img.id.should eql(1)
      img.name.should eql("Slackware")
      img.created_at.should eql("yesterday")
      img.status.should eql("g2g")
      img.meta.to_s.should eql("dendrite=flakes,graupel=balls")
    end
  end

  context "when we construct something that aint windows" do
    it "should have expected values" do
      img = HP::Cloud::ImageHelper.new(@fog_image)
      img.is_windows?.should be_false

      img.meta.hsh['hp_image_license'] = '1003'
      img.is_windows?.should be_true
    end
  end

  context "when we construct with nothing" do
    it "should have expected values" do
      img = HP::Cloud::ImageHelper.new()

      img.id.should be_nil
      img.name.should be_nil
      img.created_at.should be_nil
      img.status.should be_nil
      img.meta.to_s.should be_empty
      img.meta.hsh.should be_empty
    end
  end

  context "when we to_hash" do
    it "get all the expected values" do
      hash = HP::Cloud::ImageHelper.new(@fog_image).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("Slackware")
      hash["created_at"].should eql("yesterday")
      hash["status"].should eql("g2g")
    end
  end

  context "when we save a new one" do
    it "should call create" do
      img = HP::Cloud::ImageHelper.new()
      img.name = "bob"
      img.set_server("Hal")
      img.meta.set_metadata('luke=skywalker,han=solo')
      @server.should_receive(:create_image).with("bob", {"luke"=>"skywalker","han"=>"solo"}).and_return("1337")

      img.save.should be_true

      img.id.should eq("1337")
    end
  end

  context "when we save we cannot find server" do
    it "should get right error" do
      img = HP::Cloud::ImageHelper.new()
      img.name = "bob"
      img.set_server("Hal")
      img.meta.set_metadata('luke=skywalker,han=solo')
      @server.stub(:error_string).and_return('bogus server')
      @server.stub(:error_code).and_return(:not_found)
      @server.stub(:is_valid?).and_return(false)

      img.save.should be_false

      img.id.should be_nil
      img.error_string.should eq("bogus server")
      img.error_code.should eq(:not_found)
    end
  end

  context "when we save a new one and it fails" do
    it "should call create and return false with the errors" do
      img = HP::Cloud::ImageHelper.new()
      img.name = "bob"
      img.set_server("Hal")
      img.meta.set_metadata('luke=skywalker,han=solo')
      @server.should_receive(:create_image).with("bob", {"luke"=>"skywalker","han"=>"solo"}).and_return(nil)
      @server.stub(:error_string).and_return("Error creating image 'bob'")
      @server.stub(:error_code).and_return(:general_error)

      img.save.should be_false

      img.id.should be_nil
      img.error_string.should eq("Error creating image 'bob'")
      img.error_code.should eq(:general_error)
    end
  end

  context "when we save and there was a previous error" do
    it "fail right out" do
      img = HP::Cloud::ImageHelper.new()
      img.name = "bob"
      img.set_server("12345")
      img.meta.set_metadata('bogusmetadata')

      img.save.should be_false

      img.id.should be_nil
      img.error_string.should eq("Invalid metadata 'bogusmetadata' should be in the form 'k1=v1,k2=v2,...'")
      img.error_code.should eq(:incorrect_usage)
    end
  end
end
