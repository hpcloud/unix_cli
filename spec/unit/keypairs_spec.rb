require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Keypairs getter" do
  def mock_keypair(keyp)
    fog_keypair = double(keyp)
    fog_keypair.stub(:name).and_return(keyp)
    fog_keypair.stub(:public_key).and_return("public:" + keyp)
    fog_keypair.stub(:private_key).and_return("private:" + keyp)
    fog_keypair.stub(:fingerprint).and_return("finger:" + keyp)
    return fog_keypair
  end

  before(:each) do
    @keypairs = [ mock_keypair("keyp1"), mock_keypair("keyp2"), mock_keypair("keyp3"), mock_keypair("keyp3") ]

    @compute = double("compute")
    @compute.stub(:key_pairs).and_return(@keypairs)
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      keypairs = Keypairs.new.get()

      keypairs[0].name.should eql("keyp1")
      keypairs[1].name.should eql("keyp2")
      keypairs[2].name.should eql("keyp3")
      keypairs[3].name.should eql("keyp3")
      keypairs.length.should eql(4)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      keypairs = Keypairs.new.get(["keyp2"])

      keypairs[0].name.should eql("keyp2")
      keypairs.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      keypairs = Keypairs.new.get(["keyp1", "keyp2"])

      keypairs[0].name.should eql("keyp1")
      keypairs[1].name.should eql("keyp2")
      keypairs.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      keypairs = Keypairs.new.get(["keyp3"])

      keypairs[0].name.should eql("keyp3")
      keypairs[1].name.should eql("keyp3")
      keypairs.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      keypairs = Keypairs.new.get(["keyp3"], false)

      keypairs[0].is_valid?.should be_false
      keypairs[0].error_code.should eq(:general_error)
      keypairs[0].error_string.should eq("More than one keypair matches 'keyp3', use the id instead of name.")
      keypairs.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      keypairs = Keypairs.new.get(["bogus"])

      keypairs[0].is_valid?.should be_false
      keypairs[0].error_code.should eq(:not_found)
      keypairs[0].error_string.should eq("Cannot find a keypair matching 'bogus'.")
      keypairs.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Keypairs.new.empty?.should be_false
    end
  end
end
