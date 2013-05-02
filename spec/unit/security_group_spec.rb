require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "SecurityGroup" do
  before(:each) do
    @fog_security_group = double("fog_security_group")
    @fog_security_group.stub(:id).and_return(2)
    @fog_security_group.stub(:name).and_return("cave")
    @fog_security_group.stub(:tenant_id).and_return("89399393")
    @fog_security_group.stub(:description).and_return("allegory")
    @connection = double("connection")
  end

  context "get_keys" do
    it "should have expected values" do
      keys = HP::Cloud::SecurityGroupHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("name")
      keys[2].should eq("description")
      keys.length.should eq(3)
    end
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::SecurityGroupHelper.new(@connection, @fog_security_group)

      disk.id.should eq(2)
      disk.name.should eq("cave")
      disk.description.should eq("allegory")
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::SecurityGroupHelper.new(@connection)

      disk.id.should be_nil
      disk.name.should be_nil
      disk.description.should be_nil
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::SecurityGroupHelper.new(@connection, @fog_security_group).to_hash()

      hash["id"].should eq(2)
      hash["name"].should eq("cave")
      hash["description"].should eq("allegory")
    end
  end

  context "when we save successfully" do
    it "it is true and we get true" do
      @new_security_group = double("new_security_group")
      @new_security_group.stub(:id).and_return(3333)
      @new_security_group.stub(:save).and_return(true)
      @security_groups = double("security_groups")
      @security_groups.stub(:new).and_return(@new_security_group)
      @network = double("network")
      @network.stub(:security_groups).and_return(@security_groups)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      secg = HP::Cloud::SecurityGroupHelper.new(@connection)
      secg.name = "sun"
      secg.description = "metaphor"

      secg.save.should be_true

      secg.id.should eq(3333)
      secg.cstatus.message.should be_nil
      secg.cstatus.error_code.should eq(:success)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @security_groups = double("security_groups")
      @security_groups.stub(:new).and_return(nil)
      @network = double("network")
      @network.stub(:security_groups).and_return(@security_groups)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      secg = HP::Cloud::SecurityGroupHelper.new(@connection)
      secg.name = "sun"
      secg.description = "metaphor"

      secg.save.should be_false

      secg.cstatus.message.should eq("Error creating security group")
      secg.cstatus.error_code.should eq(:general_error)
    end
  end
end
