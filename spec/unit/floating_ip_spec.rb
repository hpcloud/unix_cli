require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FloatingIp keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::FloatingIpHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("network_id")
      keys[2].should eql("port")
      keys[3].should eql("router")
      keys[4].should eql("fixed_ip")
      keys[5].should eql("floating_ip")
      keys.length.should eql(6)
    end
  end
end

describe "FloatingIp methods" do
  before(:each) do
    @fog_floating_ip = double("fog_floating_ip")
    @fog_floating_ip.stub(:id).and_return(1)
    @fog_floating_ip.stub(:floating_network_id).and_return(22222)
    @fog_floating_ip.stub(:port_id).and_return(33333)
    @fog_floating_ip.stub(:tenant_id).and_return("234")
    @fog_floating_ip.stub(:router_id).and_return(44444)
    @fog_floating_ip.stub(:fixed_ip_address).and_return("127.0.0.1")
    @fog_floating_ip.stub(:floating_ip_address).and_return("127.0.0.2")
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::FloatingIpHelper.new(double("connection"), @fog_floating_ip)

      sot.id.should eql(1)
      sot.network_id.should eql(22222)
      sot.tenant_id.should eql("234")
      sot.port.should eql(33333)
      sot.router.should eql(44444)
      sot.fixed_ip.should eql("127.0.0.1")
      sot.floating_ip.should eql("127.0.0.2")
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::FloatingIpHelper.new(double("connection"))

      sot.id.should be_nil
      sot.network_id.should eql(nil)
      sot.tenant_id.should eql(nil)
      sot.port.should eql(nil)
      sot.router.should eql(nil)
      sot.fixed_ip.should eql(nil)
      sot.floating_ip.should eql(nil)
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

#  context "FloatingIp set_cidr" do
#    it "get all the expected values" do
#      connection = double("connection")
#      sot = HP::Cloud::FloatingIpHelper.new(connection, @fog_floating_ip)
#      sot.set_cidr("127.0.0.1").should be_true
#      sot.set_cidr("127.0.0.1/24").should be_true
#      sot.set_cidr("127.0.0.1/x").should be_false
#      sot.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.1/x")
#      sot.set_cidr("127.0.0.999/24").should be_false
#      sot.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.999/24")
#    end
#  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::FloatingIpHelper.new(double("connection"), @fog_floating_ip).to_hash()

      hash["id"].should eql(1)
      hash["network_id"].should eql(22222)
      hash["tenant_id"].should eql("234")
      hash["port"].should eq(33333)
      hash["router"].should eq(44444)
      hash["fixed_ip"].should eq("127.0.0.1")
      hash["floating_ip"].should eq("127.0.0.2")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_floating_ip = {"floating_ip"=>{"id"=>909}}
      @resposote = double("resposote")
      @resposote.stub(:body).and_return(@new_floating_ip)
      @network = double("network")
      @network.stub(:create_floating_ip).and_return(@resposote)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::FloatingIpHelper.new(@connection)
      sot.tenant_id = 100
      sot.network_id = 2222323
      sot.port = 29292
      sot.router = 00000
      sot.fixed_ip = "127.0.0.1"
      sot.floating_ip = "127.0.0.1"

      sot.save.should be_true

      sot.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("network")
      @network.stub(:create_floating_ip).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::FloatingIpHelper.new(@connection)
      sot.network_id = 999999
      sot.tenant_id = 100

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating floating IP")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
