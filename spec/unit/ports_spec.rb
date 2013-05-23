require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Ports getter" do
  def mock_port(name)
    fog_port = double(name)
    @id = 1 if @id.nil?
    fog_port.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_port.stub(:name).and_return(name)
    fog_port.stub(:tenant_id).and_return(0)
    fog_port.stub(:network_id).and_return(22020202)
    fog_port.stub(:fixed_ips).and_return([{'subnet_id'=>'subby','ip_address'=>'10.0.0.1'}])
    fog_port.stub(:mac_address).and_return("22.23.33.44.55")
    fog_port.stub(:status).and_return("STARTING")
    fog_port.stub(:admin_state_up).and_return(false)
    fog_port.stub(:device_id).and_return("99999990")
    fog_port.stub(:device_owner).and_return("billy")
    fog_port.stub(:security_groups).and_return(["one","two"])
    return fog_port
  end

  before(:each) do
    @ports = [ mock_port("sot1"), mock_port("sot2"), mock_port("sot3"), mock_port("sot3") ]
    @network = double("network")
    @network.stub(:ports).and_return(@ports)
    @connection = double("connection")
    @connection.stub(:network).and_return(@network)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      ports = Ports.new.get()

      ports[0].name.should eql("sot1")
      ports[1].name.should eql("sot2")
      ports[2].name.should eql("sot3")
      ports[3].name.should eql("sot3")
      ports.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      ports = Ports.new.get(["3"])

      ports[0].name.should eql("sot3")
      ports[0].id.to_s.should eql("3")
      ports.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      ports = Ports.new.get(["sot2"])

      ports[0].name.should eql("sot2")
      ports.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      ports = Ports.new.get(["1", "sot2"])

      ports[0].name.should eql("sot1")
      ports[1].name.should eql("sot2")
      ports.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      ports = Ports.new.get(["sot3"])

      ports[0].name.should eql("sot3")
      ports[1].name.should eql("sot3")
      ports.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      ports = Ports.new.get(["sot3"], false)

      ports[0].is_valid?.should be_false
      ports[0].cstatus.error_code.should eq(:general_error)
      ports[0].cstatus.message.should eq("More than one port matches 'sot3', use the id instead of name.")
      ports.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      ports = Ports.new.get(["bogus"])

      ports[0].is_valid?.should be_false
      ports[0].cstatus.error_code.should eq(:not_found)
      ports[0].cstatus.message.should eq("Cannot find a port matching 'bogus'.")
      ports.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Ports.new.empty?.should be_false
    end
  end
end
