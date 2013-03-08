require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Dns keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::DnsHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("size")
      keys[3].should eql("type")
      keys[4].should eql("status")
      keys.length.should eql(5)
    end
  end
end

describe "Dns methods" do
  before(:each) do
    @fog_dns = double("fog_dns")
    @fog_dns.stub(:id).and_return(1)
    @fog_dns.stub(:name).and_return("MyDns")
    @fog_dns.stub(:size).and_return(0)
    @fog_dns.stub(:type).and_return(nil)
    @fog_dns.stub(:status).and_return("available")
    @fog_dns.stub(:metadata).and_return(nil)
  end

  context "when given fog object" do
    it "should have expected values" do
      lba = HP::Cloud::DnsHelper.new(double("connection"), @fog_dns)

      lba.id.should eql(1)
      lba.name.should eql("MyDns")
      lba.size.should eql(0)
      lba.type.should be_nil
      lba.status.should eql("available")
      lba.cstatus.message.should be_nil
      lba.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      lba = HP::Cloud::DnsHelper.new(double("connection"))

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
      hash = HP::Cloud::DnsHelper.new(double("connection"), @fog_dns).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyDns")
      hash["size"].should eql(0)
      hash["type"].should be_nil
      hash["status"].should eql("available")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_dns = double("new_dns")
      @new_dns.stub(:id).and_return(909)
      @dnss = double("dnss")
      @dnss.stub(:create).and_return(@new_dns)
      @connection = double("connection")
      @connection.stub(:dns).and_return(@dnss)
      ds = HP::Cloud::DnsHelper.new(@connection)
      ds.name = 'dro'
      ds.size = 100
      ds.type = 'mysql'
      ds.status = 'available'

      ds.save.should be_true

      ds.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @dnss = double("dnss")
      @dnss.stub(:create).and_return(nil)
      @connection = double("connection")
      @connection.stub(:dns).and_return(@dnss)
      ds = HP::Cloud::DnsHelper.new(@connection)
      ds.name = 'den'
      ds.size = 100
      ds.type = 'mysql'
      ds.status = 'available'

      ds.save.should be_false

      ds.id.should be_nil
      ds.cstatus.message.should eq("Error creating dns 'den'")
      ds.cstatus.error_code.should eq(:general_error)
    end
  end
end
