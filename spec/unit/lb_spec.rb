require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lb keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::LbHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("name")
      keys[2].should eq("algorithm")
      keys[3].should eq("protocol")
      keys[4].should eq("port")
      keys[5].should eq("status")
      keys.length.should eq(6)
    end
  end
end

describe "Lb methods" do
  before(:each) do
    @fog_lb = {}
    @fog_lb[:id] = 123
    @fog_lb[:name] = "example.com."
    @fog_lb[:algorithm] = 7222
    @fog_lb[:protocol] = 22222
    @fog_lb[:port] = "test@example.com"
    @fog_lb[:status] = "up"
    @fog_lb[:created] = "4/25/13"
    @fog_lb[:updated] = "4/26/13"
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::LbHelper.new(double("connection"), @fog_lb)

      sot.id.should eq(123)
      sot.name.should eq("example.com.")
      sot.algorithm.should eq(7222)
      sot.protocol.should eq(22222)
      sot.port.should eq("test@example.com")
      sot.status.should eq("up")
      sot.created.should eq("4/25/13")
      sot.updated.should eq("4/26/13")
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::LbHelper.new(double("connection"))

      sot.id.should be_nil
      sot.name.should be_nil
      sot.algorithm.should be_nil
      sot.protocol.should be_nil
      sot.port.should be_nil
      sot.status.should be_nil
      sot.created.should be_nil
      sot.updated.should be_nil
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::LbHelper.new(double("connection"), @fog_lb).to_hash()

      hash["id"].should eq(123)
      hash["name"].should eq("example.com.")
      hash["algorithm"].should eq(7222)
      hash["protocol"].should eq(22222)
      hash["port"].should eq("test@example.com")
      hash["status"].should eq("up")
      hash["created"].should eq("4/25/13")
      hash["updated"].should eq("4/26/13")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_lb = { :id => 444 }
      @response = double("response")
      @response.stub(:body).and_return(@new_lb)
      @lbs = double("lbs")
      @lbs.stub(:create_load_balancer).and_return(@response)
      @connection = double("connection")
      @connection.stub(:lb).and_return(@lbs)
      sot = HP::Cloud::LbHelper.new(@connection)
      sot.name = 'sot'
      sot.algorithm = 100
      sot.protocol = 'http'
      sot.port = '80'

      sot.save.should be_true

      sot.id.should eq(444)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @lbs = double("lbs")
      @lbs.stub(:create_load_balancer).and_return(nil)
      @connection = double("connection")
      @connection.stub(:lb).and_return(@lbs)
      sot = HP::Cloud::LbHelper.new(@connection)
      sot.name = 'nym'
      sot.algorithm = 39393
      sot.protocol = 'http'
      sot.port = '80'

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating lb 'nym'")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
