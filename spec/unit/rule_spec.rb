# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Rule methods" do
  before(:all) do
    @fog_rule = RuleTestHelper.mock('fang')
  end

  before(:each) do
    @connection = double("connection")
    @security_group = double("security_group")
  end

  context "get_keys" do
    it "should have expected values" do
      keys = HP::Cloud::RuleHelper.get_keys()

      keys[0].should eq("id")
      keys[1].should eq("source")
      keys[2].should eq("type")
      keys[3].should eq("protocol")
      keys[4].should eq("direction")
      keys[5].should eq("cidr")
      keys[6].should eq("from")
      keys[7].should eq("to")
      keys.length.should eq(8)
    end
  end

  context "when given fog object" do
    it "should have expected values" do
      item = HP::Cloud::RuleHelper.new(@connection, @security_group, @fog_rule)

      item.id.should eq(1)
      item.source.should eq("fang")
      item.name.should eq("fang")
      item.protocol.should eq("icmp")
      item.direction.should eq("egress")
      item.type.should eq("IPv4")
      item.from.should eq(2222)
      item.to.should eq(3333)
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

      hash["id"].should eq(1)
      hash["name"].should eq("fang")
      hash["source"].should eq("fang")
      hash["direction"].should eq("egress")
      hash["protocol"].should eq("icmp")
      hash["type"].should eq("IPv4")
      hash["tenant_id"].should eq('2134234234')
      hash["to"].should eq(3333)
      hash["from"].should eq(2222)
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
