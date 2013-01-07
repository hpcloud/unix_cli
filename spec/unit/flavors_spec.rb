require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Flavors getter" do
  def mock_flavor(name)
    fog_flavor = double(name)
    @id = 1 if @id.nil?
    fog_flavor.stub(:id).and_return(@id)
    @id += 1
    fog_flavor.stub(:name).and_return("standard."+name)
    fog_flavor.stub(:ram).and_return(1024 + @id)
    fog_flavor.stub(:disk).and_return(30 + @id)
    return fog_flavor
  end

  before(:each) do
    @flavors = [ mock_flavor("xsmall"), mock_flavor("small"), mock_flavor("large"), mock_flavor("large") ]

    @compute = double("compute")
    @compute.stub(:flavors).and_return(@flavors)
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      flavors = Flavors.new.get()

      flavors[0].name.should eql("xsmall")
      flavors[1].name.should eql("small")
      flavors[2].name.should eql("large")
      flavors[3].name.should eql("large")
      flavors.length.should eql(4)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      flavors = Flavors.new.get(["standard.small"])

      flavors[0].name.should eql("small")
      flavors.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      flavors = Flavors.new.get(["xsmall", "small"])

      flavors[0].name.should eql("xsmall")
      flavors[1].name.should eql("small")
      flavors.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      flavors = Flavors.new.get(["large"])

      flavors[0].name.should eql("large")
      flavors[1].name.should eql("large")
      flavors.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      flavors = Flavors.new.get(["large"], false)

      flavors[0].is_valid?.should be_false
      flavors[0].cstatus.error_code.should eq(:general_error)
      flavors[0].cstatus.message.should eq("More than one flavor matches 'large', use the id instead of name.")
      flavors.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      flavors = Flavors.new.get(["bogus"])

      flavors[0].is_valid?.should be_false
      flavors[0].cstatus.error_code.should eq(:not_found)
      flavors[0].cstatus.message.should eq("Cannot find a flavor matching 'bogus'.")
      flavors.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Flavors.new.empty?.should be_false
    end
  end
end
