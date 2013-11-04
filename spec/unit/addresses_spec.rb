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

describe "Addresses getter" do
  def mock_address(addy)
    fog_address = double(addy)
    @id = 1 if @id.nil?
    fog_address.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_address.stub(:ip).and_return(addy)
    fog_address.stub(:fixed_ip).and_return("127.3.3.3")
    fog_address.stub(:instance_id).and_return(444)
    return fog_address
  end

  before(:each) do
    @addresses = [ mock_address("addy1"), mock_address("addy2"), mock_address("addy3"), mock_address("addy3") ]

    @compute = double("compute")
    @compute.stub(:addresses).and_return(@addresses)
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      addresses = Addresses.new.get()

      addresses[0].ip.should eql("addy1")
      addresses[1].ip.should eql("addy2")
      addresses[2].ip.should eql("addy3")
      addresses[3].ip.should eql("addy3")
      addresses.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      addresses = Addresses.new.get(["3"])

      addresses[0].ip.should eql("addy3")
      addresses[0].id.to_s.should eql("3")
      addresses.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      addresses = Addresses.new.get(["addy2"])

      addresses[0].ip.should eql("addy2")
      addresses.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      addresses = Addresses.new.get(["1", "addy2"])

      addresses[0].ip.should eql("addy1")
      addresses[1].ip.should eql("addy2")
      addresses.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      addresses = Addresses.new.get(["addy3"])

      addresses[0].ip.should eql("addy3")
      addresses[1].ip.should eql("addy3")
      addresses.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      addresses = Addresses.new.get(["addy3"], false)

      addresses[0].is_valid?.should be_false
      addresses[0].cstatus.error_code.should eq(:general_error)
      addresses[0].cstatus.message.should eq("More than one ip address matches 'addy3', use the id instead of name.")
      addresses.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      addresses = Addresses.new.get(["bogus"])

      addresses[0].is_valid?.should be_false
      addresses[0].cstatus.error_code.should eq(:not_found)
      addresses[0].cstatus.message.should eq("Cannot find an ip address matching 'bogus'.")
      addresses.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Addresses.new.empty?.should be_false
    end
  end
end
