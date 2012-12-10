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
      img.meta.hsh['owner'] = 'bob'
      img.is_private?.should be_true
      img.meta.hsh['owner'] = ''
      img.is_private?.should be_false
      img.meta.hsh['owner'] = nil
      img.is_private?.should be_false
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

  context "when we check get OS" do
    it "should return some guess" do
      img = HP::Cloud::ImageHelper.new()

      img.name ="ActiveState Stackato v2.6.6 - Partner Image"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="BitNami WebPack 1.4-0-linux-ubuntu-12.04 64-bit - Partner Image"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="BitNami Drupal 7.17-0-hp-linux-ubuntu-12.04 64-bit - Partner Image"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="BitNami DevPack 1.3-0-linux-ubuntu-12.04 64-bit - Partner Image"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Precise 12.04 LTS Server 64-bit 20121026 DEPLOY-1150"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Quantal 12.10 Server 64-bit 20121017 DEPLOY-1149"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="cli_test_img1"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="ActiveState Stackato v2.4.3 - Partner Image"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Windows Server 2008 Enterprise SP2 x86 Volume License 20121031 DEPLOY-1078"
      img.os.should eq(:windows)
      img.login.should eq('Administrator')

      img.name ="Windows Server 2008 Enterprise SP2 x64 Volume License 20121031 DEPLOY-1077"
      img.os.should eq(:windows)
      img.login.should eq('Administrator')

      img.name ="Windows Server 2008 R2 Enterprise SP1 x64 Volume License 20121005 DEPLOY-1049"
      img.os.should eq(:windows)
      img.login.should eq('Administrator')

      img.name ="Ubuntu Precise 12.04 LTS Server 64-bit (VOLUME-BOOTABLE)"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Windows Server 2008 R2 Ent SP1 x64 20120829 + SSH (NO os_type)"
      img.os.should eq(:windows)
      img.login.should eq('Administrator')

      img.name ="ActiveState Stackato v2.2.3 - Partner Image (deprecated)"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="ActiveState Stackato v2.2.2 - Partner Image (deprecated)"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="CentOS 5.8 Server 64-bit 20120828 DEPLOY-934"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="Fedora 16 Server 64-bit 20120518 DEPLOY-723"
      img.os.should eq(:fedora)
      img.login.should eq('root')

      img.name ="Ubuntu Precise 12.04 LTS Server 64-bit 20120424 DEPLOY-629"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Fedora 16 Server 64-bit Test 2 w/ -ssh 20120404 DEPLOY-552"
      img.os.should eq(:fedora)
      img.login.should eq('root')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20120311 DEPLOY-549"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Fedora 16 Server 64-bit 20120404 (deprecated) DEPLOY-552"
      img.os.should eq(:fedora)
      img.login.should eq('root')

      img.name ="Debian Squeeze 6.0.3 Server 64-bit 20120123 DEPLOY-301.2"
      img.os.should eq(:debian)
      img.login.should eq('root')

      img.name ="Debian Squeeze 6.0.3 Server 64-bit 20120123 (Ramdisk) DEPLOY-301.2"
      img.os.should eq(:debian)
      img.login.should eq('root')

      img.name ="Debian Squeeze 6.0.3 Server 64-bit 20120123 (Kernel) DEPLOY-301.2"
      img.os.should eq(:debian)
      img.login.should eq('root')

      img.name ="CentOS 6.2 Server 64-bit 20120125 DEPLOY-301.1"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="CentOS 6.2 Server 64-bit 20120125 (Ramdisk) DEPLOY-301.1"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="CentOS 6.2 Server 64-bit 20120125 (Kernel) DEPLOY-301.1"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="pub-Fri_Jan__6_15:38:51_UTC_2012"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20111212 (deprecated) DEPLOY-122-TEST"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20111212 (Kernel) (deprecated) DEPLOY-122-TEST"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20111212 (Kernel) (deprecated) DEPLOY-122-TEST"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="CentOS 5.6 Server 64-bit 20111207 (deprecated) DEPLOY-166 (deprecated)"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="CentOS 5.6 Server 64-bit 20111207 (Ramdisk) (deprecated) DEPLOY-166 (deprecated)"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="CentOS 5.6 Server 64-bit 20111207 (Kernel) (deprecated) DEPLOY-166 (deprecated)"
      img.os.should eq(:centos)
      img.login.should eq('root')

      img.name ="Ubuntu Lucid 10.04 LTS Server 64-bit 20111212 DEPLOY-167"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Lucid 10.04 LTS Server 64-bit 20111212 (Kernel) DEPLOY-167"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Maverick 10.10 Server 64-bit 20111212 DEPLOY-168"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Maverick 10.10 Server 64-bit 20111212 (Kernel) DEPLOY-168"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20111212 (deprecated) DEPLOY-170               "
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Oneiric 11.10 Server 64-bit 20111212 (Kernel) (deprecated) DEPLOY-170"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Natty 11.04 Server 64-bit 20111212 DEPLOY-169"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="Ubuntu Natty 11.04 Server 64-bit 20111212 (Kernel) DEPLOY-169"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="natty-server-cloudimg-amd64.img-w-timeout-120-w-debugging"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="natty-server-cloudimg-amd64-vmlinuz-virtual-w-timeout-120-w-debugging"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="ubuntuTestDiskimage"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

      img.name ="ubuntuTestKernel"
      img.os.should eq(:ubuntu)
      img.login.should eq('ubuntu')

    end
  end
end
