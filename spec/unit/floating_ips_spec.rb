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

describe "Subnets getter" do
  def mock_subnet(name)
    fog_subnet = double(name)
    @id = 1 if @id.nil?
    fog_subnet.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_subnet.stub(:name).and_return(name)
    fog_subnet.stub(:tenant_id).and_return(0)
    fog_subnet.stub(:network_id).and_return(22020202)
    fog_subnet.stub(:cidr).and_return("127.0.0.1")
    fog_subnet.stub(:ip_version).and_return(4)
    fog_subnet.stub(:dns_nameservers).and_return(22222)
    fog_subnet.stub(:allocation_pools).and_return([])
    fog_subnet.stub(:host_routes).and_return([])
    fog_subnet.stub(:gateway_ip).and_return("127.0.0.2")
    fog_subnet.stub(:enable_dhcp).and_return(false)
    return fog_subnet
  end

  before(:each) do
    @subnets = [ mock_subnet("sn1"), mock_subnet("sn2"), mock_subnet("sn3"), mock_subnet("sn3") ]
    @network = double("network")
    @network.stub(:subnets).and_return(@subnets)
    @connection = double("connection")
    @connection.stub(:network).and_return(@network)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      subnets = Subnets.new.get()

      subnets[0].name.should eql("sn1")
      subnets[1].name.should eql("sn2")
      subnets[2].name.should eql("sn3")
      subnets[3].name.should eql("sn3")
      subnets.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      subnets = Subnets.new.get(["3"])

      subnets[0].name.should eql("sn3")
      subnets[0].id.to_s.should eql("3")
      subnets.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      subnets = Subnets.new.get(["sn2"])

      subnets[0].name.should eql("sn2")
      subnets.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      subnets = Subnets.new.get(["1", "sn2"])

      subnets[0].name.should eql("sn1")
      subnets[1].name.should eql("sn2")
      subnets.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      subnets = Subnets.new.get(["sn3"])

      subnets[0].name.should eql("sn3")
      subnets[1].name.should eql("sn3")
      subnets.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      subnets = Subnets.new.get(["sn3"], false)

      subnets[0].is_valid?.should be_false
      subnets[0].cstatus.error_code.should eq(:general_error)
      subnets[0].cstatus.message.should eq("More than one subnet matches 'sn3', use the id instead of name.")
      subnets.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      subnets = Subnets.new.get(["bogus"])

      subnets[0].is_valid?.should be_false
      subnets[0].cstatus.error_code.should eq(:not_found)
      subnets[0].cstatus.message.should eq("Cannot find a subnet matching 'bogus'.")
      subnets.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Subnets.new.empty?.should be_false
    end
  end
end
