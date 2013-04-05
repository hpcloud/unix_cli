require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Port keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::PortHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("network_id")
      keys[3].should eql("fixed_ips")
      keys[4].should eql("mac_address")
      keys[5].should eql("status")
      keys[6].should eql("admin_state")
      keys[7].should eql("device_id")
      keys[8].should eql("device_owner")
      keys.length.should eql(9)
    end
  end
end

describe "Port methods" do
  before(:each) do
    @fog_port = double("fog_port")
    @fog_port.stub(:id).and_return(1)
    @fog_port.stub(:name).and_return("MyPort")
    @fog_port.stub(:tenant_id).and_return("234")
    @fog_port.stub(:network_id).and_return("999999")
    @fog_port.stub(:fixed_ips).and_return([{'subnet_id'=>"4",'ip_address'=>"127.0.0.1"}])
    @fog_port.stub(:mac_address).and_return("12.12.12.12.12.12")
    @fog_port.stub(:status).and_return("ACTIVE")
    @fog_port.stub(:admin_state_up).and_return(true)
    @fog_port.stub(:device_id).and_return("12722222")
    @fog_port.stub(:device_owner).and_return("bob")
    @fog_port.stub(:security_groups).and_return(["groupo","groupp"])
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::PortHelper.new(double("connection"), @fog_port)

      sot.id.should eql(1)
      sot.name.should eql("MyPort")
      sot.tenant_id.should eql("234")
      sot.network_id.should eql("999999")
      sot.fixed_ips.should eql("4,127.0.0.1")
      sot.mac_address.should eql("12.12.12.12.12.12")
      sot.status.should eql("ACTIVE")
      sot.admin_state_up.should eql(true)
      sot.admin_state.should eql("up")
      sot.device_id.should eql("12722222")
      sot.device_owner.should eql("bob")
      sot.groups.should eql(["groupo","groupp"])
      sot.security_groups.should eql("groupo,groupp")
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::PortHelper.new(double("connection"))

      sot.id.should be_nil
      sot.name.should be_nil
      sot.tenant_id.should be_nil
      sot.network_id.should be_nil
      sot.fixed_ips.should be_nil
      sot.mac_address.should be_nil
      sot.status.should be_nil
      sot.admin_state_up.should be_nil
      sot.admin_state.should be_nil
      sot.device_id.should be_nil
      sot.device_owner.should be_nil
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "Port set_fixed_ips" do
    it "get all the expected values" do
      connection = double("connection")
      sn = HP::Cloud::PortHelper.new(connection, @fog_port)
      sn.set_fixed_ips("111111,127.0.0.1").should be_true
      sn.set_fixed_ips("24,127.0.0.1;25,127.1.1.1").should be_true
      sn.set_fixed_ips("127.0.0.1;x").should be_false
      sn.cstatus.to_s.should eq("Invalid fixed IPs '127.0.0.1;x' must be semicolon separated list of subnet_id,ip_address")
      sn.set_fixed_ips("127.0.0.999,24,23333").should be_false
      sn.cstatus.to_s.should eq("Invalid fixed IPs '127.0.0.999,24,23333' must be semicolon separated list of subnet_id,ip_address")
    end
  end

  context "Port set_security_groups" do
    it "get all the expected values" do
      connection = double("connection")
      sn = HP::Cloud::PortHelper.new(connection, @fog_port)
      sn.set_security_groups("one,two").should be_true
      sn.set_security_groups("uno").should be_true
      sn.set_security_groups("").should be_true
      sn.set_security_groups(nil).should be_true
      #sn.set_security_groups(",,").should be_false
      #sn.cstatus.to_s.should eq("Invalid security groups '' must be comma separated list of groups")
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::PortHelper.new(double("connection"), @fog_port).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyPort")
      hash["tenant_id"].should eql("234")
      hash["network_id"].should eq("999999")
      hash["fixed_ips"].should eq("4,127.0.0.1")
      hash["mac_address"].should eq("12.12.12.12.12.12")
      hash["status"].should eq("ACTIVE")
      hash["admin_state_up"].should eq(true)
      hash["admin_state"].should eq("up")
      hash["device_id"].should eq("12722222")
      hash["device_owner"].should eq("bob")
      hash["groups"].should eq(["groupo","groupp"])
      hash["security_groups"].should eq("groupo,groupp")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_port = {"port"=>{"id"=>909}}
      @resposote = double("resposote")
      @resposote.stub(:body).and_return(@new_port)
      @network = double("network")
      @network.stub(:create_port).and_return(@resposote)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::PortHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100
      sot.network_id = 2222323

      sot.save.should be_true

      sot.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("network")
      @network.stub(:create_port).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::PortHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100
      sot.network_id = 2222333

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating port 'quantum'")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
