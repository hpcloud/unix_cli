require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lbs getter" do
  def mock_lb(name)
    fog_lb = {}
    @id = 1 if @id.nil?
    fog_lb[:id] = @id.to_s
    @id += 1
    fog_lb[:name] = name
    fog_lb[:algorithm] = 888
    fog_lb[:protocol] = "tcp"
    fog_lb[:port] = "909"
    fog_lb[:created] = "today"
    fog_lb[:updated] = "now"
    return fog_lb
  end

  before(:each) do
    @lbs = [ mock_lb("sot1"), mock_lb("sot2"), mock_lb("sot3"), mock_lb("sot3") ]
    @body = { "domains" => @lbs }
    @response = double("response")
    @response.stub(:body).and_return(@body)
    @lb = double("lb")
    @lb.stub(:list_load_balancers).and_return(@response)
    @connection = double("connection")
    @connection.stub(:lb).and_return(@lb)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      lbs = Lbs.new.get()

      lbs[0].name.should eql("sot1")
      lbs[1].name.should eql("sot2")
      lbs[2].name.should eql("sot3")
      lbs[3].name.should eql("sot3")
      lbs.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      lbs = Lbs.new.get(["3"])

      lbs[0].name.should eql("sot3")
      lbs[0].id.to_s.should eql("3")
      lbs.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      lbs = Lbs.new.get(["sot2"])

      lbs[0].name.should eql("sot2")
      lbs.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      lbs = Lbs.new.get(["1", "sot2"])

      lbs[0].name.should eql("sot1")
      lbs[1].name.should eql("sot2")
      lbs.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      lbs = Lbs.new.get(["sot3"])

      lbs[0].name.should eql("sot3")
      lbs[1].name.should eql("sot3")
      lbs.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      lbs = Lbs.new.get(["sot3"], false)

      lbs[0].is_valid?.should be_false
      lbs[0].cstatus.error_code.should eq(:general_error)
      lbs[0].cstatus.message.should eq("More than one lb matches 'sot3', use the id instead of name.")
      lbs.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      lbs = Lbs.new.get(["bogus"])

      lbs[0].is_valid?.should be_false
      lbs[0].cstatus.error_code.should eq(:not_found)
      lbs[0].cstatus.message.should eq("Cannot find a lb matching 'bogus'.")
      lbs.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Lbs.new.empty?.should be_false
    end
  end
end
