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

describe "Dnss getter" do
  def mock_dns(name)
    fog_dns = {}
    @id = 1 if @id.nil?
    fog_dns[:id] = @id.to_s
    @id += 1
    fog_dns[:name] = name
    fog_dns[:ttl] = 888
    fog_dns[:serial] = "123123"
    fog_dns[:email] = "asdf@example.com"
    fog_dns[:created_at] = "today"
    fog_dns[:updated_at] = "now"
    return fog_dns
  end

  before(:each) do
    @dnss = [ mock_dns("sot1"), mock_dns("sot2"), mock_dns("sot3"), mock_dns("sot3") ]
    @body = { "domains" => @dnss }
    @response = double("response")
    @response.stub(:body).and_return(@body)
    @dns = double("dns")
    @dns.stub(:list_domains).and_return(@response)
    @connection = double("connection")
    @connection.stub(:dns).and_return(@dns)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      dnss = Dnss.new.get()

      dnss[0].name.should eql("sot1")
      dnss[1].name.should eql("sot2")
      dnss[2].name.should eql("sot3")
      dnss[3].name.should eql("sot3")
      dnss.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      dnss = Dnss.new.get(["3"])

      dnss[0].name.should eql("sot3")
      dnss[0].id.to_s.should eql("3")
      dnss.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      dnss = Dnss.new.get(["sot2"])

      dnss[0].name.should eql("sot2")
      dnss.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      dnss = Dnss.new.get(["1", "sot2"])

      dnss[0].name.should eql("sot1")
      dnss[1].name.should eql("sot2")
      dnss.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      dnss = Dnss.new.get(["sot3"])

      dnss[0].name.should eql("sot3")
      dnss[1].name.should eql("sot3")
      dnss.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      dnss = Dnss.new.get(["sot3"], false)

      dnss[0].is_valid?.should be_false
      dnss[0].cstatus.error_code.should eq(:general_error)
      dnss[0].cstatus.message.should eq("More than one dns matches 'sot3', use the id instead of name.")
      dnss.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      dnss = Dnss.new.get(["bogus"])

      dnss[0].is_valid?.should be_false
      dnss[0].cstatus.error_code.should eq(:not_found)
      dnss[0].cstatus.message.should eq("Cannot find a dns matching 'bogus'.")
      dnss.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Dnss.new.empty?.should be_false
    end
  end
end
