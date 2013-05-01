require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Dns keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::DnsHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("name")
      keys[2].should eq("ttl")
      keys[3].should eq("serial")
      keys[4].should eq("email")
      keys[5].should eq("created_at")
      keys.length.should eq(6)
    end
  end
end

describe "Dns methods" do
  before(:each) do
    @fog_dns = {}
    @fog_dns[:id] = 123
    @fog_dns[:name] = "example.com."
    @fog_dns[:ttl] = 7222
    @fog_dns[:serial] = 22222
    @fog_dns[:email] = "test@example.com"
    @fog_dns[:created_at] = "4/25/13"
    @fog_dns[:updated_at] = "4/26/13"
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::DnsHelper.new(double("connection"), @fog_dns)

      sot.id.should eq(123)
      sot.name.should eq("example.com.")
      sot.ttl.should eq(7222)
      sot.serial.should eq(22222)
      sot.email.should eq("test@example.com")
      sot.created_at.should eq("4/25/13")
      sot.updated_at.should eq("4/26/13")
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::DnsHelper.new(double("connection"))

      sot.id.should be_nil
      sot.name.should be_nil
      sot.ttl.should be_nil
      sot.serial.should be_nil
      sot.email.should be_nil
      sot.created_at.should be_nil
      sot.updated_at.should be_nil
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::DnsHelper.new(double("connection"), @fog_dns).to_hash()

      hash["id"].should eq(123)
      hash["name"].should eq("example.com.")
      hash["ttl"].should eq(7222)
      hash["serial"].should eq(22222)
      hash["email"].should eq("test@example.com")
      hash["created_at"].should eq("4/25/13")
      hash["updated_at"].should eq("4/26/13")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_dns = { :id => 444 }
      @response = double("response")
      @response.stub(:body).and_return(@new_dns)
      @dnss = double("dnss")
      @dnss.stub(:create_domain).and_return(@response)
      @connection = double("connection")
      @connection.stub(:dns).and_return(@dnss)
      sot = HP::Cloud::DnsHelper.new(@connection)
      sot.name = 'sot'
      sot.ttl = 100
      sot.email = 'what@whatever.com'

      sot.save.should be_true

      sot.id.should eq(444)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @dnss = double("dnss")
      @dnss.stub(:create_domain).and_return(nil)
      @connection = double("connection")
      @connection.stub(:dns).and_return(@dnss)
      sot = HP::Cloud::DnsHelper.new(@connection)
      sot.name = 'nym'
      sot.ttl = 39393
      sot.email = 'this@that.com'

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating dns 'nym'")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
