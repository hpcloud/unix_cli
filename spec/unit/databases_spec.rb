require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Databases getter" do
  def mock_database(name)
    fog_database = double(name)
    @id = 1 if @id.nil?
    fog_database.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_database.stub(:name).and_return(name)
    fog_database.stub(:size).and_return(0)
    fog_database.stub(:type).and_return(nil)
    fog_database.stub(:status).and_return("available")
    fog_database.stub(:metadata).and_return(nil)
    return fog_database
  end

  before(:each) do
    @databases = [ mock_database("dbs1"), mock_database("dbs2"), mock_database("dbs3"), mock_database("dbs3") ]
    @block = double("block")
    @block.stub(:databases).and_return(@databases)

    @compute = double("compute")
    @compute.stub(:servers).and_return([])
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    @connection.stub(:block).and_return(@block)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      databases = Databases.new.get()

      databases[0].name.should eql("dbs1")
      databases[1].name.should eql("dbs2")
      databases[2].name.should eql("dbs3")
      databases[3].name.should eql("dbs3")
      databases.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      databases = Databases.new.get(["3"])

      databases[0].name.should eql("dbs3")
      databases[0].id.to_s.should eql("3")
      databases.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      databases = Databases.new.get(["dbs2"])

      databases[0].name.should eql("dbs2")
      databases.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      databases = Databases.new.get(["1", "dbs2"])

      databases[0].name.should eql("dbs1")
      databases[1].name.should eql("dbs2")
      databases.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      databases = Databases.new.get(["dbs3"])

      databases[0].name.should eql("dbs3")
      databases[1].name.should eql("dbs3")
      databases.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      databases = Databases.new.get(["dbs3"], false)

      databases[0].is_valid?.should be_false
      databases[0].cstatus.error_code.should eq(:general_error)
      databases[0].cstatus.message.should eq("More than one database matches 'dbs3', use the id instead of name.")
      databases.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      databases = Databases.new.get(["bogus"])

      databases[0].is_valid?.should be_false
      databases[0].cstatus.error_code.should eq(:not_found)
      databases[0].cstatus.message.should eq("Cannot find a database matching 'bogus'.")
      databases.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Databases.new.empty?.should be_false
    end
  end
end
