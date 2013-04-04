require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Router keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::RouterHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("admin_state")
      keys[3].should eql("status")
      keys[4].should eql("gateway")
      keys.length.should eql(5)
    end
  end
end

describe "Router methods" do
  before(:each) do
    @fog_router = double("fog_router")
    @fog_router.stub(:id).and_return(1)
    @fog_router.stub(:name).and_return("MyRouter")
    @fog_router.stub(:tenant_id).and_return("234")
    @fog_router.stub(:external_gateway_info).and_return({'network_id'=>'netty'})
    @fog_router.stub(:admin_state_up).and_return(true)
    @fog_router.stub(:status).and_return("ACTIVE")
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::RouterHelper.new(double("connection"), @fog_router)

      sot.id.should eql(1)
      sot.name.should eql("MyRouter")
      sot.tenant_id.should eql("234")
      sot.external_gateway_info.should eql({'network_id'=>'netty'})
      sot.gateway.should eql("netty")
      sot.admin_state_up.should eql(true)
      sot.admin_state.should eql("up")
      sot.status.should eql("ACTIVE")
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::RouterHelper.new(double("connection"))

      sot.id.should be_nil
      sot.name.should be_nil
      sot.tenant_id.should be_nil
      sot.external_gateway_info.should be_nil
      sot.gateway.should be_nil
      sot.admin_state_up.should be_nil
      sot.admin_state.should be_nil
      sot.status.should be_nil
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "Router set_gateway" do
    it "get all the expected values" do
      connection = double("connection")
      sot = HP::Cloud::RouterHelper.new(connection, @fog_router)
      sot.set_gateway("127.0.0.1").should be_true
      sot.cstatus.to_s.should eq("")
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::RouterHelper.new(double("connection"), @fog_router).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyRouter")
      hash["tenant_id"].should eql("234")
      hash["gateway"].should eq("netty")
      hash["admin_state"].should eq("up")
      hash["status"].should eq("ACTIVE")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_router = {"router"=>{"id"=>909}}
      @resposote = double("resposote")
      @resposote.stub(:body).and_return(@new_router)
      @network = double("network")
      @network.stub(:create_router).and_return(@resposote)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::RouterHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100
      sot.set_gateway("2222323")
      sot.admin_state_up = true

      sot.save.should be_true

      sot.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("network")
      @network.stub(:create_router).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::RouterHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating router 'quantum'")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
