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
    @fog_server.stub(:network_name).and_return("hpcloud")
    @fog_server.stub(:addresses).and_return({:k=>:v})
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
      srv = HP::Cloud::ServerHelper.new(double("connection"), @fog_server)

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
      srv = HP::Cloud::ServerHelper.new(double("connection"))

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
      hash = HP::Cloud::ServerHelper.new(double("connection"), @fog_server).to_hash()

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

  context "when we call set_flavor with good flavor" do
    it "it sets the flavor and returns true" do
      @connection = double("connection")
      flavor = double("flavor_flav")
      flavor.stub(:id).and_return(1959)
      flavor.stub(:name).and_return('flavor_flav')
      flavor.stub(:ram).and_return(1024)
      flavor.stub(:disk).and_return(60)
      @connection.stub(:flavors).and_return([flavor])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_flavor('flavor_flav').should be_true

      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
      srv.flavor.should eq(1959)
    end
  end

  context "when we call set_image with bogus image" do
    it "it returns false and sets error" do
      @connection = double("connection")
      @connection.stub(:images).and_return([])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_image('bogus').should be_false

      srv.cstatus.message.should eq("Cannot find a image matching 'bogus'.")
      srv.cstatus.error_code.should eq(:not_found)
      srv.is_windows?.should be_false
      srv.image.should be_nil
    end
  end

  context "when we call set_image with good image" do
    it "it sets the image and returns true" do
      meta = double("metadata")
      meta.stub(:key).and_return('hp_image_license')
      meta.stub(:value).and_return('999')
      @connection = double("connection")
      image = double("windows_image")
      image.stub(:id).and_return(2222)
      image.stub(:name).and_return('good')
      image.stub(:created_at).and_return('now')
      image.stub(:status).and_return('g2g')
      image.stub(:metadata).and_return([meta])
      @connection.stub(:images).and_return([image])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_image('good').should be_true

      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
      srv.is_windows?.should be_true
      srv.image.should eq(2222)
    end
  end

  context "when we call set_volume with bogus volume" do
    it "it returns false and sets error" do
      @block = double("connection")
      @block.stub(:volumes).and_return([])
      @connection = double("connection")
      servers = double("servers")
      servers.stub(:all).and_return([])
      @connection.stub(:servers).and_return(servers)
      Connection.instance.stub(:compute).and_return(@connection)
      Connection.instance.stub(:block).and_return(@block)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_volume('bogus').should be_false

      srv.cstatus.message.should eq("Cannot find a volume matching 'bogus'.")
      srv.cstatus.error_code.should eq(:not_found)
      srv.is_windows?.should be_false
      srv.volume.should be_nil
    end
  end

  context "when we call set_volume with good volume" do
    it "it sets the volume and returns true" do
      meta = double("metadata")
      meta.stub(:key).and_return('hp_volume_license')
      meta.stub(:value).and_return('999')
      volume = double("volume")
      volume.stub(:id).and_return(2222)
      volume.stub(:name).and_return('good')
      volume.stub(:size).and_return(10)
      volume.stub(:type).and_return('')
      volume.stub(:created_at).and_return('now')
      volume.stub(:status).and_return('g2g')
      volume.stub(:description).and_return('volley')
      volume.stub(:metadata).and_return([meta])
      volume.stub(:attachments).and_return([])
      @block = double("block")
      @block.stub(:volumes).and_return([volume])
      @connection = double("connection")
      servers = double("servers")
      servers.stub(:all).and_return([])
      @connection.stub(:servers).and_return(servers)
      Connection.instance.stub(:block).and_return(@block)
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_volume('good').should be_true

      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
      srv.is_windows?.should be_false
      srv.volume.should eq(2222)
    end
  end

  context "when we call set_keypair with nothing" do
    it "it returns true and does nothing" do
      @connection = double("connection")
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_keypair(nil).should be_true

      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
      srv.keyname.should be_nil
    end
  end

  context "when we call set_keypair with bogus value" do
    it "it returns false and sets error" do
      @connection = double("connection")
      @connection.stub(:key_pairs).and_return([])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_keypair('bogus').should be_false

      srv.cstatus.message.should eq("Cannot find a keypair matching 'bogus'.")
      srv.cstatus.error_code.should eq(:not_found)
      srv.keyname.should be_nil
    end
  end

  context "when we call set_keypair with something good" do
    it "it returns true and sets keyname" do
      @connection = double("connection")
      keypair = double("keypair")
      keypair.stub(:name).and_return('good')
      keypair.stub(:fingerprint).and_return('fingerprint')
      keypair.stub(:public_key).and_return('public')
      keypair.stub(:private_key).and_return('private')
      @connection.stub(:key_pairs).and_return([keypair])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_keypair('good').should be_true

      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
      srv.keyname.should eq('good')
    end
  end

  context "when we call set_private_key with good file" do
    it "it gets the private key data" do
      @connection = double("connection")
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_private_key("spec/fixtures/files/foo.txt").should be_true

      srv.private_key.should eq("This is a foo file.")
      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
    end
  end

  context "when we call set_private_key with bad file" do
    it "it gets the private key data" do
      @connection = double("connection")
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_private_key("non/existent/file.txt").should be_false

      srv.private_key.should be_nil
      path = File.expand_path(File.dirname(__FILE__) + '/../..')
      srv.cstatus.message.should eq("Error reading private key file 'non/existent/file.txt': No such file or directory - #{path}/non/existent/file.txt")
      srv.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "when we call set_private_key with nothing on non windows" do
    it "it returns true and sets nothing" do
      @connection = double("connection")
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)

      srv.set_private_key(nil).should be_true

      srv.private_key.should be_nil
      srv.cstatus.message.should be_nil
      srv.cstatus.error_code.should eq(:success)
    end
  end

  context "when we call set_private_key with nothing on windows" do
    it "it returns returns false and an error" do
      meta = double("metadata")
      meta.stub(:key).and_return('hp_image_license')
      meta.stub(:value).and_return('999')
      @connection = double("connection")
      image = double("windows_image")
      image.stub(:id).and_return(2222)
      image.stub(:name).and_return('good')
      image.stub(:created_at).and_return('now')
      image.stub(:status).and_return('g2g')
      image.stub(:metadata).and_return([meta])
      @connection.stub(:images).and_return([image])
      Connection.instance.stub(:compute).and_return(@connection)
      srv = HP::Cloud::ServerHelper.new(@connection)
      srv.set_image('good').should be_true

      srv.set_private_key(nil).should be_false

      srv.private_key.should be_nil
      srv.cstatus.message.should eq("You must specify the private key file if you want to create a windows instance.")
      srv.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "when we call set_security_groups" do
    it "it changes the security_groups and returns true" do
      srv = HP::Cloud::ServerHelper.new(double("connection"))

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
      srv = HP::Cloud::ServerHelper.new(double("connection"))
      srv.set_security_groups('something').should be_true

      srv.set_security_groups('').should be_true

      srv.security_groups.should eq('')
      srv.security.length.should eq(0)
    end
  end

  context "when we call set_security_groups with nil" do
    it "it doesn't change the security_groups" do
      srv = HP::Cloud::ServerHelper.new(double("connection"))
      srv.set_security_groups('something').should be_true

      srv.set_security_groups(nil).should be_true

      srv.security_groups.should eq('something')
      srv.security[0].should eq('something')
      srv.security.length.should eq(1)
    end
  end

  context "when we call set_security_groups with quotes" do
    it "it changes the security_groups and returns false" do
      srv = HP::Cloud::ServerHelper.new(double("connection"))
      srv.set_security_groups('un","deux",trois').should be_false
      srv.cstatus.message.should eq("Invalid security group 'un\",\"deux\",trois' should be comma separated list")
      srv.cstatus.error_code.should eq(:incorrect_usage)
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
      @connection = double("connection")
      @connection.stub(:servers).and_return(@servers)
      srv = HP::Cloud::ServerHelper.new(@connection)
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
      @connection = double("connection")
      @connection.stub(:servers).and_return(servers)
      srv = HP::Cloud::ServerHelper.new(@connection)
      srv.name = "bob"
      srv.flavor = "101"
      srv.image = "122"
      srv.keyname = "default"
      srv.set_security_groups('x-wing,y-wing')
      srv.meta.set_metadata('luke=skywalker,han=solo')

      srv.save.should be_false

      srv.id.should be_nil
      srv.cstatus.message.should eq("Error creating server 'bob'")
      srv.cstatus.error_code.should eq(:general_error)
    end
  end

  context "when we save and there was a previous error" do
    it "should call create" do
      srv = HP::Cloud::ServerHelper.new(double("connection"))
      srv.name = "bob"
      srv.flavor = "101"
      srv.image = "122"
      srv.keyname = "default"
      srv.set_security_groups('x-wing,y-wing')
      srv.meta.set_metadata('whiskeytangofoxtrot')

      srv.save.should be_false

      srv.id.should be_nil
      srv.cstatus.message.should eq("Invalid metadata 'whiskeytangofoxtrot' should be in the form 'k1=v1,k2=v2,...'")
      srv.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "when we save and there was a previous error" do
    it "should call create" do
      srv = HP::Cloud::ServerHelper.new(double("connection"))
      srv.name = "bob"
      srv.flavor = "101"
      srv.keyname = "default"
      srv.set_private_key('bogus')

      srv.save.should be_false

      srv.id.should be_nil
      srv.cstatus.message.should include("Error reading private key file 'bogus'")
      srv.cstatus.error_code.should eq(:incorrect_usage)
    end
  end
end
