require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Flavor keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::FlavorHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("name")
      keys[2].should eq("ram")
      keys[3].should eq("disk")
      keys.length.should eq(4)
    end
  end
end

describe "Flavor methods" do
  before(:each) do
    @fog_flavor = double("fog_flavor")
    @fog_flavor.stub(:id).and_return(3232)
    @fog_flavor.stub(:name).and_return("standard.xsmall")
    @fog_flavor.stub(:ram).and_return(1024)
    @fog_flavor.stub(:disk).and_return(30)
    @connection = double("connection")
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::FlavorHelper.new(@connection, @fog_flavor)

      disk.id.should eq(3232)
      disk.name.should eq("xsmall")
      disk.fullname.should eq("standard.xsmall")
      disk.ram.should eq(1024)
      disk.disk.should eq(30)
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::FlavorHelper.new(@connection)

      disk.id.should be_nil
      disk.name.should be_nil
      disk.fullname.should be_nil
      disk.ram.should be_nil
      disk.disk.should be_nil
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::FlavorHelper.new(@connection, @fog_flavor).to_hash()

      hash["id"].should eq(3232)
      hash["name"].should eq("xsmall")
      hash["fullname"].should eq("standard.xsmall")
      hash["ram"].should eq(1024)
      hash["disk"].should eq(30)
    end
  end

  context "when we save" do
    it "it is always fails" do
      flav = HP::Cloud::FlavorHelper.new(@connection)
      flav.name = "ton"
      flav.ram = 2048
      flav.disk = 300

      flav.save.should be_false

      flav.error_string.should eq("Save of flavors not supported at this time")
      flav.error_code.should eq(:general_error)
    end
  end
end
