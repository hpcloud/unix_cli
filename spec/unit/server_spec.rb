require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Server class" do

  before(:each) do
    @fog_server = double("server")
    @fog_server.stub(:id).and_return(1)
    @fog_server.stub(:name).and_return("Hal")
    @fog_server.stub(:flavor_id).and_return("chocolate")
    @fog_server.stub(:image_id).and_return("122")
    @fog_server.stub(:public_ip_address).and_return("10.0.0.1")
    @fog_server.stub(:private_ip_address).and_return("172.1.1.1")
    @fog_server.stub(:key_name).and_return("key")
    @security_groups = [{"name" => "one"}, {"name" => "two"}]
    @fog_server.stub(:security_groups).and_return(@security_groups)
    @fog_server.stub(:created_at).and_return("today")
    @fog_server.stub(:state).and_return("ACTIVE")
    @fog_server.stub(:metadata).and_return([])
  end

  context "when we get keys" do
    it "should have expected values" do
      keys = HP::Cloud::ServerHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("flavor")
      keys[3].should eql("image")
      keys[4].should eql("public_ip")
      keys[5].should eql("private_ip")
      keys[6].should eql("keyname")
      keys[7].should eql("security_groups")
      keys[8].should eql("created")
      keys[9].should eql("state")
      keys.length.should eql(10)
    end
  end

  context "when we construct" do
    it "should have expected values" do
      srv = HP::Cloud::ServerHelper.new(double("compute"), @fog_server)

      srv.id.should eql(1)
      srv.name.should eql("Hal")
      srv.flavor.should eql("chocolate")
      srv.image.should eql("122")
      srv.public_ip.should eql("10.0.0.1")
      srv.private_ip.should eql("172.1.1.1")
      srv.keyname.should eql("key")
      srv.security_groups.should eql("one, two")
      srv.created.should eql("today")
      srv.state.should eql("ACTIVE")
      srv.meta.to_s.should eql("")
    end
  end

  context "when we construct with nothing" do
    it "should have expected values" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))

      srv.id.should be_nil
      srv.name.should be_nil
      srv.flavor.should be_nil
      srv.image.should be_nil
      srv.public_ip.should be_nil
      srv.private_ip.should be_nil
      srv.keyname.should be_nil
      srv.security_groups.should be_nil
      srv.created.should be_nil
      srv.state.should be_nil
      srv.meta.to_s.should be_empty
    end
  end

  context "when we to_hash" do
    it "get all the expected values" do
      hash = HP::Cloud::ServerHelper.new(double("compute"), @fog_server).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("Hal")
      hash["flavor"].should eql("chocolate")
      hash["image"].should eql("122")
      hash["public_ip"].should eql("10.0.0.1")
      hash["private_ip"].should eql("172.1.1.1")
      hash["keyname"].should eql("key")
      hash["security_groups"].should eql("one, two")
      hash["created"].should eql("today")
      hash["state"].should eql("ACTIVE")
    end
  end

  context "when we call set_security_groups" do
    it "it changes the security_groups and returns true" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))

      srv.set_security_groups('un,deux,trois').should be_true

      srv.security_groups.should eq('un,deux,trois')
      srv.security[0].should eq('un')
      srv.security[1].should eq('deux')
      srv.security[2].should eq('trois')
      srv.security.length.should eq(3)
    end
  end

  context "when we call set_security_groups with empty string" do
    it "it changes the security_groups to nothing and returns true" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))
      srv.set_security_groups('something').should be_true

      srv.set_security_groups('').should be_true

      srv.security_groups.should eq('')
      srv.security.length.should eq(0)
    end
  end

  context "when we call set_security_groups with nil" do
    it "it doesn't change the security_groups" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))
      srv.set_security_groups('something').should be_true

      srv.set_security_groups(nil).should be_true

      srv.security_groups.should eq('something')
      srv.security[0].should eq('something')
      srv.security.length.should eq(1)
    end
  end

  context "when we call set_security_groups with quotes" do
    it "it changes the security_groups and returns false" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))
      srv.set_security_groups('un","deux",trois').should be_false
      srv.error_string.should eq("Invalid security group 'un\",\"deux\",trois' should be comma separated list")
      srv.error_code.should eq(:incorrect_usage)
    end
  end

  context "when we create image successfully" do
    it "should return id" do
      name = "snapshot"
      hsh = {"a"=>"A","b"=>"B"}
      resp = double("resp")
      resp.stub(:headers).and_return({"Location"=>"http://127.0.0.1/images/21"})
      fog_server = double("fog_server")
      fog_server.stub(:id).and_return(222)
      fog_server.stub(:name).and_return("Hal")
      fog_server.stub(:flavor_id).and_return(201)
      fog_server.stub(:image_id).and_return(101)
      fog_server.stub(:public_ip_address).and_return("172.0.0.1")
      fog_server.stub(:private_ip_address).and_return("10.0.0.1")
      fog_server.stub(:key_name).and_return("key")
      fog_server.stub(:security_groups).and_return(nil)
      fog_server.stub(:created_at).and_return(nil)
      fog_server.stub(:state).and_return(nil)
      fog_server.stub(:metadata).and_return(nil)
      fog_server.should_receive(:create_image).with(name, hsh).and_return(resp)
      srv = HP::Cloud::ServerHelper.new(double("compute"), fog_server)

      id = srv.create_image(name, hsh)

      id.should eq("21")
    end
  end

  context "when create image fails" do
    it "should return set the error" do
    end
  end

  context "when we save a new one" do
    it "should call create" do
      hsh = {:flavor_id => "101",
             :image_id => "122",
             :name => "bob",
             :key_name => "default",
             :security_groups => ["x-wing","y-wing"],
             :metadata => {"luke"=>"skywalker","han"=>"solo"}}
      @new_server = double("new_server")
      @new_server.stub(:id).and_return(909)
      @servers = double("servers")
      @servers.should_receive(:create).with(hsh).and_return(@new_server)
      @compute = double("compute")
      @compute.stub(:servers).and_return(@servers)
      srv = HP::Cloud::ServerHelper.new(@compute)
      srv.name = "bob"
      srv.flavor = "101"
      srv.image = "122"
      srv.keyname = "default"
      srv.set_security_groups('x-wing,y-wing')
      srv.meta.set_metadata('luke=skywalker,han=solo')

      srv.save.should be_true

      srv.id.should eq(909)
    end
  end

  context "when we save a new one and it fails" do
    it "should call create" do
      servers = double("servers")
      servers.stub(:create).and_return(nil)
      @compute = double("compute")
      @compute.stub(:servers).and_return(servers)
      srv = HP::Cloud::ServerHelper.new(@compute)
      srv.name = "bob"
      srv.flavor = "101"
      srv.image = "122"
      srv.keyname = "default"
      srv.set_security_groups('x-wing,y-wing')
      srv.meta.set_metadata('luke=skywalker,han=solo')

      srv.save.should be_false

      srv.id.should be_nil
      srv.error_string.should eq("Error creating server 'bob'")
      srv.error_code.should eq(:general_error)
    end
  end

  context "when we save and there was a previous error" do
    it "should call create" do
      srv = HP::Cloud::ServerHelper.new(double("compute"))
      srv.name = "bob"
      srv.flavor = "101"
      srv.image = "122"
      srv.keyname = "default"
      srv.set_security_groups('x-wing,y-wing')
      srv.meta.set_metadata('whiskeytangofoxtrot')

      srv.save.should be_false

      srv.id.should be_nil
      srv.error_string.should eq("Invalid metadata 'whiskeytangofoxtrot' should be in the form 'k1=v1,k2=v2,...'")
      srv.error_code.should eq(:incorrect_usage)
    end
  end
end