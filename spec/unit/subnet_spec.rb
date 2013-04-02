require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Subnet keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::SubnetHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("network_id")
      keys[3].should eql("cidr")
      keys[4].should eql("ip_version")
      keys[5].should eql("dns_nameservers")
      keys[6].should eql("allocation_pools")
      keys[7].should eql("host_routes")
      keys[8].should eql("gateway_ip")
      keys[9].should eql("enable_dhcp")
      keys.length.should eql(10)
    end
  end
end

describe "Subnet methods" do
  before(:each) do
    @fog_subnet = double("fog_subnet")
    @fog_subnet.stub(:id).and_return(1)
    @fog_subnet.stub(:name).and_return("MySubnet")
    @fog_subnet.stub(:tenant_id).and_return("234")
    @fog_subnet.stub(:network_id).and_return(222)
    @fog_subnet.stub(:cidr).and_return("127.0.0.1/1")
    @fog_subnet.stub(:ip_version).and_return(4)
    @fog_subnet.stub(:dns_nameservers).and_return(222323)
    @fog_subnet.stub(:allocation_pools).and_return([])
    @fog_subnet.stub(:host_routes).and_return([])
    @fog_subnet.stub(:gateway_ip).and_return("127.0.0.1")
    @fog_subnet.stub(:enable_dhcp).and_return(true)
  end

  context "when given fog object" do
    it "should have expected values" do
      ns = HP::Cloud::SubnetHelper.new(double("connection"), @fog_subnet)

      ns.id.should eql(1)
      ns.name.should eql("MySubnet")
      ns.tenant_id.should eql("234")
      ns.network_id.should eql(222)
      ns.cidr.should eql("127.0.0.1/1")
      ns.ip_version.should eql(4)
      ns.dns_nameservers.should eql(222323)
      ns.allocation_pools.should eql([])
      ns.host_routes.should eql([])
      ns.gateway_ip.should eql("127.0.0.1")
      ns.enable_dhcp.should eql(true)
      ns.cstatus.message.should be_nil
      ns.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      ns = HP::Cloud::SubnetHelper.new(double("connection"))

      ns.id.should be_nil
      ns.name.should be_nil
      ns.tenant_id.should be_nil
      ns.network_id.should be_nil
      ns.cidr.should be_nil
      ns.ip_version.should be_nil
      ns.dns_nameservers.should be_nil
      ns.allocation_pools.should be_nil
      ns.host_routes.should be_nil
      ns.gateway_ip.should be_nil
      ns.enable_dhcp.should be_nil
      ns.cstatus.message.should be_nil
      ns.cstatus.error_code.should eq(:success)
    end
  end

  context "Subnet set_cidr" do
    it "get all the expected values" do
      connection = double("connection")
      sn = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sn.set_cidr("127.0.0.1").should be_true
      sn.set_cidr("127.0.0.1/24").should be_true
      sn.set_cidr("127.0.0.1/x").should be_false
      sn.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.1/x")
      sn.set_cidr("127.0.0.999/24").should be_false
      sn.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.999/24")
    end
  end

  context "Subnet set_ip_version" do
    it "get all the expected values" do
      connection = double("connection")
      sn = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sn.set_ip_version("4").should be_true
      sn.set_ip_version("6").should be_true
      sn.set_ip_version(6).should be_true
      sn.set_ip_version("5").should be_false
      sn.cstatus.to_s.should eq("Invalid IP version '5'")
    end
  end
  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::SubnetHelper.new(double("connection"), @fog_subnet).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MySubnet")
      hash["tenant_id"].should eql("234")
      hash["network_id"].should eq(222)
      hash["cidr"].should eq("127.0.0.1/1")
      hash["ip_version"].should eq(4)
      hash["dns_nameservers"].should eq(222323)
      hash["allocation_pools"].should eq([])
      hash["host_routes"].should eq([])
      hash["gateway_ip"].should eq("127.0.0.1")
      hash["enable_dhcp"].should be_true
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_subnet = {"subnet"=>{"id"=>909}}
      @response = double("response")
      @response.stub(:body).and_return(@new_subnet)
      @network = double("network")
      @network.stub(:create_subnet).and_return(@response)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      ns = HP::Cloud::SubnetHelper.new(@connection)
      ns.name = 'quantum'
      ns.tenant_id = 100
      ns.network_id = 2222323
      ns.cidr = "127.0.0.1"
      ns.ip_version = 6
      ns.dns_nameservers = 2222
      ns.allocation_pools = [123,333]
      ns.host_routes = [123,333]
      ns.gateway_ip = "127.0.0.2"
      ns.enable_dhcp = true

      ns.save.should be_true

      ns.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("network")
      @network.stub(:create_subnet).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      ns = HP::Cloud::SubnetHelper.new(@connection)
      ns.name = 'quantum'
      ns.tenant_id = 100

      ns.save.should be_false

      ns.id.should be_nil
      ns.cstatus.message.should eq("Error creating subnet 'quantum'")
      ns.cstatus.error_code.should eq(:general_error)
    end
  end
end
