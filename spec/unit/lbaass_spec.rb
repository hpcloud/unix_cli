require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lbaass getter" do
  def mock_lbaas(name)
    fog_lbaas = double(name)
    @id = 1 if @id.nil?
    fog_lbaas.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_lbaas.stub(:name).and_return(name)
    fog_lbaas.stub(:size).and_return(0)
    fog_lbaas.stub(:type).and_return(nil)
    fog_lbaas.stub(:status).and_return("available")
    fog_lbaas.stub(:metadata).and_return(nil)
    return fog_lbaas
  end

  before(:each) do
    @lbaass = [ mock_lbaas("lbs1"), mock_lbaas("lbs2"), mock_lbaas("lbs3"), mock_lbaas("lbs3") ]
    @connection = double("connection")
    @connection.stub(:lbaas).and_return(@lbaass)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      lbaass = Lbaass.new.get()

      lbaass[0].name.should eql("lbs1")
      lbaass[1].name.should eql("lbs2")
      lbaass[2].name.should eql("lbs3")
      lbaass[3].name.should eql("lbs3")
      lbaass.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      lbaass = Lbaass.new.get(["3"])

      lbaass[0].name.should eql("lbs3")
      lbaass[0].id.to_s.should eql("3")
      lbaass.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      lbaass = Lbaass.new.get(["lbs2"])

      lbaass[0].name.should eql("lbs2")
      lbaass.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      lbaass = Lbaass.new.get(["1", "lbs2"])

      lbaass[0].name.should eql("lbs1")
      lbaass[1].name.should eql("lbs2")
      lbaass.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      lbaass = Lbaass.new.get(["lbs3"])

      lbaass[0].name.should eql("lbs3")
      lbaass[1].name.should eql("lbs3")
      lbaass.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      lbaass = Lbaass.new.get(["lbs3"], false)

      lbaass[0].is_valid?.should be_false
      lbaass[0].cstatus.error_code.should eq(:general_error)
      lbaass[0].cstatus.message.should eq("More than one lbaas matches 'lbs3', use the id instead of name.")
      lbaass.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      lbaass = Lbaass.new.get(["bogus"])

      lbaass[0].is_valid?.should be_false
      lbaass[0].cstatus.error_code.should eq(:not_found)
      lbaass[0].cstatus.message.should eq("Cannot find a lbaas matching 'bogus'.")
      lbaass.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Lbaass.new.empty?.should be_false
    end
  end
end
