require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Keypair keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::KeypairHelper.get_keys()

      keys[0].should eq("name")
      keys[1].should eq("fingerprint")
      keys.length.should eq(2)
    end
  end
end

describe "Keypair methods" do
  before(:each) do
    @fog_keypair = double("fog_keypair")
    @fog_keypair.stub(:name).and_return("skeleton")
    @fog_keypair.stub(:public_key).and_return("bones")
    @fog_keypair.stub(:private_key).and_return("cartilage")
    @fog_keypair.stub(:fingerprint).and_return("exoskeleton")
    @connection = double("connection")
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::KeypairHelper.new(@connection, @fog_keypair)

      disk.id.should eq("skeleton")
      disk.name.should eq("skeleton")
      disk.public_key.should eq("bones")
      disk.private_key.should eq("cartilage")
      disk.fingerprint.should eq("exoskeleton")
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::KeypairHelper.new(@connection)

      disk.id.should be_nil
      disk.name.should be_nil
      disk.public_key.should be_nil
      disk.private_key.should be_nil
      disk.fingerprint.should be_nil
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::KeypairHelper.new(@connection, @fog_keypair).to_hash()

      hash["id"].should eq("skeleton")
      hash["name"].should eq("skeleton")
      hash["public_key"].should eq("bones")
      hash["private_key"].should eq("cartilage")
      hash["fingerprint"].should eq("exoskeleton")
    end
  end

  context "when we save successfully" do
    it "it is true and we get true" do
      @new_keypair = double("new_keypair")
      @keypairs = double("keypairs")
      @keypairs.stub(:create).and_return(@new_keypair)
      @compute = double("compute")
      @compute.stub(:key_pairs).and_return(@keypairs)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)
      keyp.name = "roll"
      keyp.private_key = "away"
      keyp.fingerprint = "your"

      keyp.save.should be_true

      keyp.error_string.should be_nil
      keyp.error_code.should be_nil
    end
  end

  context "when we save public_key successfully" do
    it "it is true and we get true" do
      @new_keypair = double("new_keypair")
      @compute = double("compute")
      @compute.stub(:create_key_pair).and_return(@new_keypair)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)
      keyp.name = "roll"
      keyp.public_key = "away"

      keyp.save.should be_true

      keyp.error_string.should be_nil
      keyp.error_code.should be_nil
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @keypairs = double("keypairs")
      @keypairs.stub(:create).and_return(nil)
      @compute = double("compute")
      @compute.stub(:key_pairs).and_return(@keypairs)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      keyp = HP::Cloud::KeypairHelper.new(@connection)

      keyp.save.should be_false

      keyp.error_string.should eq("Error creating ip keypair")
      keyp.error_code.should eq(:general_error)
    end
  end
end
