require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Rule keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::RuleHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("source")
      keys[2].should eq("protocol")
      keys[3].should eq("from")
      keys[4].should eq("to")
      keys.length.should eq(5)
    end
  end
end

describe "Rule methods" do
  before(:each) do
    @fog_rule = { 'id' => 2,
                  'group' => {'name' => 'fang'},
                  'ip_protocol' => 'tcp',
                  'from_port' => 3389,
                  'to_port' => 3390
                }
    @connection = double("connection")
    @security_group = double("security_group")
  end

  context "when given fog object" do
    it "should have expected values" do
      item = HP::Cloud::RuleHelper.new(@connection, @security_group, @fog_rule)

      item.id.should eq(2)
      item.source.should eq("fang")
      item.protocol.should eq("tcp")
      item.from.should eq(3389)
      item.to.should eq(3390)
      item.cstatus.message.should be_nil
      item.cstatus.error_code.should eq(:success)
    end
  end

  context "when given fog object" do
    it "should have expected values" do
      @fog_rule = { 'id' => 2,
                    'group' => {},
                    'ip_range' => {'cidr' => '0.0.0.0/0'},
                    'ip_protocol' => 'tcp',
                    'from_port' => 3389,
                    'to_port' => 3390
                  }
      item = HP::Cloud::RuleHelper.new(@connection, @security_group, @fog_rule)

      item.id.should eq(2)
      item.source.should eq("0.0.0.0/0")
      item.protocol.should eq("tcp")
      item.from.should eq(3389)
      item.to.should eq(3390)
      item.cstatus.message.should be_nil
      item.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      item = HP::Cloud::RuleHelper.new(@connection, @security_group)

      item.id.should be_nil
      item.source.should be_nil
      item.protocol.should be_nil
      item.from.should be_nil
      item.to.should be_nil
      item.cstatus.message.should be_nil
      item.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::RuleHelper.new(@connection, @security_group, @fog_rule).to_hash()

      hash["id"].should eq(2)
      hash["source"].should eq("fang")
      hash["protocol"].should eq("tcp")
      hash["from"].should eq(3389)
      hash["to"].should eq(3390)
    end
  end

  context "when we save successfully" do
    it "it is true and we get true" do
      @body = { 'security_group_rule' => { 'id' => 444 } }
      @response = double("response")
      @response.stub(:body).and_return(@body)
      @fog = double("fog")
      @fog.stub(:create_rule).and_return(@response)
      @security_group.stub(:fog).and_return(@fog)
      item = HP::Cloud::RuleHelper.new(@connection, @security_group)
      item.source = "sun"
      item.protocol = "metaphor"
      item.from = 9991
      item.to = 9999

      item.save.should be_true

      item.id.should eq(444)
      item.fog.should eq(@body['security_group_rule'])
      item.cstatus.message.should be_nil
      item.cstatus.error_code.should eq(:success)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @fog = double("fog")
      @fog.stub(:create_rule).and_return(nil)
      @security_group.stub(:fog).and_return(@fog)
      item = HP::Cloud::RuleHelper.new(@connection, @security_group)
      item.source = "sun"
      item.protocol = "metaphor"
      item.from = 9991
      item.to = 9999

      item.save.should be_false

      item.cstatus.message.should eq("Error creating rule")
      item.cstatus.error_code.should eq(:general_error)
    end
  end
end
