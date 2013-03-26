require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lbaas keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::LbaasHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("size")
      keys[3].should eql("type")
      keys[4].should eql("status")
      keys.length.should eql(5)
    end
  end
end

describe "Lbaas methods" do
  before(:each) do
    @fog_lbaas = double("fog_lbaas")
    @fog_lbaas.stub(:id).and_return(1)
    @fog_lbaas.stub(:name).and_return("MyLbaas")
    @fog_lbaas.stub(:size).and_return(0)
    @fog_lbaas.stub(:type).and_return(nil)
    @fog_lbaas.stub(:status).and_return("available")
    @fog_lbaas.stub(:metadata).and_return(nil)
  end

  context "when given fog object" do
    it "should have expected values" do
      lba = HP::Cloud::LbaasHelper.new(double("connection"), @fog_lbaas)

      lba.id.should eql(1)
      lba.name.should eql("MyLbaas")
      lba.size.should eql(0)
      lba.type.should be_nil
      lba.status.should eql("available")
      lba.cstatus.message.should be_nil
      lba.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      lba = HP::Cloud::LbaasHelper.new(double("connection"))

      lba.id.should be_nil
      lba.name.should be_nil
      lba.size.should be_nil
      lba.type.should be_nil
      lba.status.should be_nil
      lba.cstatus.message.should be_nil
      lba.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::LbaasHelper.new(double("connection"), @fog_lbaas).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyLbaas")
      hash["size"].should eql(0)
      hash["type"].should be_nil
      hash["status"].should eql("available")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_lbaas = double("new_lbaas")
      @new_lbaas.stub(:id).and_return(909)
      @lbaass = double("lbaass")
      @lbaass.stub(:create).and_return(@new_lbaas)
      @connection = double("connection")
      @connection.stub(:lbaas).and_return(@lbaass)
      lbs = HP::Cloud::LbaasHelper.new(@connection)
      lbs.name = 'dro'
      lbs.size = 100
      lbs.type = 'mysql'
      lbs.status = 'available'

      lbs.save.should be_true

      lbs.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @lbaass = double("lbaass")
      @lbaass.stub(:create).and_return(nil)
      @connection = double("connection")
      @connection.stub(:lbaas).and_return(@lbaass)
      lbs = HP::Cloud::LbaasHelper.new(@connection)
      lbs.name = 'den'
      lbs.size = 100
      lbs.type = 'mysql'
      lbs.status = 'available'

      lbs.save.should be_false

      lbs.id.should be_nil
      lbs.cstatus.message.should eq("Error creating lbaas 'den'")
      lbs.cstatus.error_code.should eq(:general_error)
    end
  end
end
