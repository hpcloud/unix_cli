require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Database keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::DatabaseHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("size")
      keys[3].should eql("type")
      keys[4].should eql("status")
      keys.length.should eql(5)
    end
  end
end

describe "Database methods" do
  before(:each) do
    @fog_database = double("fog_database")
    @fog_database.stub(:id).and_return(1)
    @fog_database.stub(:name).and_return("MyDatabase")
    @fog_database.stub(:size).and_return(0)
    @fog_database.stub(:type).and_return(nil)
    @fog_database.stub(:status).and_return("available")
    @fog_database.stub(:metadata).and_return(nil)
  end

  context "when given fog object" do
    it "should have expected values" do
      dbase = HP::Cloud::DatabaseHelper.new(double("connection"), @fog_database)

      dbase.id.should eql(1)
      dbase.name.should eql("MyDatabase")
      dbase.size.should eql(0)
      dbase.type.should be_nil
      dbase.status.should eql("available")
      dbase.cstatus.message.should be_nil
      dbase.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      dbase = HP::Cloud::DatabaseHelper.new(double("connection"))

      dbase.id.should be_nil
      dbase.name.should be_nil
      dbase.size.should be_nil
      dbase.type.should be_nil
      dbase.status.should be_nil
      dbase.cstatus.message.should be_nil
      dbase.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::DatabaseHelper.new(double("connection"), @fog_database).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyDatabase")
      hash["size"].should eql(0)
      hash["type"].should be_nil
      hash["status"].should eql("available")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_database = double("new_database")
      @new_database.stub(:id).and_return(909)
      @databases = double("databases")
      @databases.stub(:create).and_return(@new_database)
      @block = double("block")
      @block.stub(:databases).and_return(@databases)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      dbs = HP::Cloud::DatabaseHelper.new(@connection)
      dbs.name = 'dro'
      dbs.size = 100
      dbs.type = 'mysql'
      dbs.status = 'available'

      dbs.save.should be_true

      dbs.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @databases = double("databases")
      @databases.stub(:create).and_return(nil)
      @block = double("block")
      @block.stub(:databases).and_return(@databases)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      dbs = HP::Cloud::DatabaseHelper.new(@connection)
      dbs.name = 'den'
      dbs.size = 100
      dbs.type = 'mysql'
      dbs.status = 'available'

      dbs.save.should be_false

      dbs.id.should be_nil
      dbs.cstatus.message.should eq("Error creating database 'den'")
      dbs.cstatus.error_code.should eq(:general_error)
    end
  end
end
