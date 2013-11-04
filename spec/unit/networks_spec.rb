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

describe "Networks getter" do
  def mock_network(name)
    fog_network = double(name)
    @id = 1 if @id.nil?
    fog_network.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_network.stub(:name).and_return(name)
    fog_network.stub(:size).and_return(0)
    fog_network.stub(:tenant_id).and_return("1231231")
    fog_network.stub(:status).and_return("ACTIVE")
    fog_network.stub(:shared).and_return(nil)
    fog_network.stub(:admin_state_up).and_return(true)
    fog_network.stub(:subnets).and_return(nil)
    fog_network.stub(:router_external).and_return(false)
    return fog_network
  end

  before(:each) do
    @networks = [ mock_network("nw1"), mock_network("nw2"), mock_network("nw3"), mock_network("nw3") ]
    @network = double("network")
    @network.stub(:networks).and_return(@networks)
    @connection = double("connection")
    @connection.stub(:network).and_return(@network)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      networks = Networks.new.get()

      networks[0].name.should eql("nw1")
      networks[1].name.should eql("nw2")
      networks[2].name.should eql("nw3")
      networks[3].name.should eql("nw3")
      networks.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      networks = Networks.new.get(["3"])

      networks[0].name.should eql("nw3")
      networks[0].id.to_s.should eql("3")
      networks.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      networks = Networks.new.get(["nw2"])

      networks[0].name.should eql("nw2")
      networks.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      networks = Networks.new.get(["1", "nw2"])

      networks[0].name.should eql("nw1")
      networks[1].name.should eql("nw2")
      networks.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      networks = Networks.new.get(["nw3"])

      networks[0].name.should eql("nw3")
      networks[1].name.should eql("nw3")
      networks.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      networks = Networks.new.get(["nw3"], false)

      networks[0].is_valid?.should be_false
      networks[0].cstatus.error_code.should eq(:general_error)
      networks[0].cstatus.message.should eq("More than one network matches 'nw3', use the id instead of name.")
      networks.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      networks = Networks.new.get(["bogus"])

      networks[0].is_valid?.should be_false
      networks[0].cstatus.error_code.should eq(:not_found)
      networks[0].cstatus.message.should eq("Cannot find a network matching 'bogus'.")
      networks.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Networks.new.empty?.should be_false
    end
  end
end
