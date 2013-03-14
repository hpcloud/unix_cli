require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Dnss getter" do
  def mock_dns(name)
    fog_dns = double(name)
    @id = 1 if @id.nil?
    fog_dns.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_dns.stub(:name).and_return(name)
    fog_dns.stub(:size).and_return(0)
    fog_dns.stub(:type).and_return(nil)
    fog_dns.stub(:status).and_return("available")
    fog_dns.stub(:metadata).and_return(nil)
    return fog_dns
  end

  before(:each) do
    @dnss = [ mock_dns("ds1"), mock_dns("ds2"), mock_dns("ds3"), mock_dns("ds3") ]
    @connection = double("connection")
    @connection.stub(:dnss).and_return(@dnss)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      dnss = Dnss.new.get()

      dnss[0].name.should eql("ds1")
      dnss[1].name.should eql("ds2")
      dnss[2].name.should eql("ds3")
      dnss[3].name.should eql("ds3")
      dnss.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      dnss = Dnss.new.get(["3"])

      dnss[0].name.should eql("ds3")
      dnss[0].id.to_s.should eql("3")
      dnss.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      dnss = Dnss.new.get(["ds2"])

      dnss[0].name.should eql("ds2")
      dnss.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      dnss = Dnss.new.get(["1", "ds2"])

      dnss[0].name.should eql("ds1")
      dnss[1].name.should eql("ds2")
      dnss.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      dnss = Dnss.new.get(["ds3"])

      dnss[0].name.should eql("ds3")
      dnss[1].name.should eql("ds3")
      dnss.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      dnss = Dnss.new.get(["ds3"], false)

      dnss[0].is_valid?.should be_false
      dnss[0].cstatus.error_code.should eq(:general_error)
      dnss[0].cstatus.message.should eq("More than one dns matches 'ds3', use the id instead of name.")
      dnss.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      dnss = Dnss.new.get(["bogus"])

      dnss[0].is_valid?.should be_false
      dnss[0].cstatus.error_code.should eq(:not_found)
      dnss[0].cstatus.message.should eq("Cannot find a dns matching 'bogus'.")
      dnss.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Dnss.new.empty?.should be_false
    end
  end
end
