require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Network keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::NetworkHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("status")
      keys[3].should eql("shared")
      keys[4].should eql("admin_state")
      keys[5].should eql("subnets")
      keys.length.should eql(6)
    end
  end
end

describe "Network methods" do
  before(:each) do
    @fog_network = double("fog_network")
    @fog_network.stub(:id).and_return(1)
    @fog_network.stub(:name).and_return("MyNetwork")
    @fog_network.stub(:status).and_return("available")
    @fog_network.stub(:tenant_id).and_return(234)
    @fog_network.stub(:shared).and_return(false)
    @fog_network.stub(:admin_state_up).and_return("up")
    @fog_network.stub(:subnets).and_return([4])
    @fog_network.stub(:router_external).and_return(false)
  end

  context "when given fog object" do
    it "should have expected values" do
      ns = HP::Cloud::NetworkHelper.new(double("connection"), @fog_network)

      ns.id.should eql(1)
      ns.name.should eql("MyNetwork")
      ns.status.should eql("available")
      ns.shared.should eql(false)
      ns.admin_state_up.should eq("up")
      ns.subnets.should eq("4")
      ns.cstatus.message.should be_nil
      ns.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      ns = HP::Cloud::NetworkHelper.new(double("connection"))

      ns.id.should be_nil
      ns.name.should be_nil
      ns.tenant_id.should be_nil
      ns.status.should be_nil
      ns.subnets.should be_nil
      ns.shared.should be_false
      ns.admin_state_up.should be_true
      ns.cstatus.message.should be_nil
      ns.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::NetworkHelper.new(double("connection"), @fog_network).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyNetwork")
      hash["tenant_id"].should eql(234)
      hash["status"].should eql("available")
      hash["subnets"].should eq("4")
      hash["shared"].should be_false
      hash["admin_state_up"].should eq("up")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_network = double("new_network")
      @new_network.stub(:body).and_return({"network"=>{"id"=>909,"status"=>"ACTIVE"}})
      @network = double("networks")
      @network.stub(:create_network).and_return(@new_network)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      ns = HP::Cloud::NetworkHelper.new(@connection)
      ns.name = 'quantum'
      ns.tenant_id = 100
      ns.status = 'available'
      ns.subnets = 32
      ns.shared = true
      ns.admin_state_up = true

      ns.save.should be_true

      ns.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("networks")
      @network.stub(:create_network).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      ns = HP::Cloud::NetworkHelper.new(@connection)
      ns.name = 'quantum'
      ns.tenant_id = 100
      ns.status = 'available'
      ns.subnets = 32
      ns.shared = true
      ns.admin_state_up = true

      ns.save.should be_false

      ns.id.should be_nil
      ns.cstatus.message.should eq("Error creating network 'quantum'")
      ns.cstatus.error_code.should eq(:general_error)
    end
  end
end
