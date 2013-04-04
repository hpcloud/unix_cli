require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Routers getter" do
  def mock_router(name)
    fog_router = double(name)
    @id = 1 if @id.nil?
    fog_router.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_router.stub(:name).and_return(name)
    fog_router.stub(:tenant_id).and_return(0)
    fog_router.stub(:external_gateway_info).and_return({'network_id'=>'netty'})
    fog_router.stub(:admin_state_up).and_return(true)
    fog_router.stub(:status).and_return("ACTIVE")
    return fog_router
  end

  before(:each) do
    @routers = [ mock_router("sot1"), mock_router("sot2"), mock_router("sot3"), mock_router("sot3") ]
    @network = double("network")
    @network.stub(:routers).and_return(@routers)
    @connection = double("connection")
    @connection.stub(:network).and_return(@network)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      routers = Routers.new.get()

      routers[0].name.should eql("sot1")
      routers[1].name.should eql("sot2")
      routers[2].name.should eql("sot3")
      routers[3].name.should eql("sot3")
      routers.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      routers = Routers.new.get(["3"])

      routers[0].name.should eql("sot3")
      routers[0].id.to_s.should eql("3")
      routers.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      routers = Routers.new.get(["sot2"])

      routers[0].name.should eql("sot2")
      routers.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      routers = Routers.new.get(["1", "sot2"])

      routers[0].name.should eql("sot1")
      routers[1].name.should eql("sot2")
      routers.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      routers = Routers.new.get(["sot3"])

      routers[0].name.should eql("sot3")
      routers[1].name.should eql("sot3")
      routers.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      routers = Routers.new.get(["sot3"], false)

      routers[0].is_valid?.should be_false
      routers[0].cstatus.error_code.should eq(:general_error)
      routers[0].cstatus.message.should eq("More than one router matches 'sot3', use the id instead of name.")
      routers.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      routers = Routers.new.get(["bogus"])

      routers[0].is_valid?.should be_false
      routers[0].cstatus.error_code.should eq(:not_found)
      routers[0].cstatus.message.should eq("Cannot find a router matching 'bogus'.")
      routers.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Routers.new.empty?.should be_false
    end
  end
end
