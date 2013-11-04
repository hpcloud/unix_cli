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

describe "Address keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::AddressHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("ip")
      keys[2].should eql("fixed_ip")
      keys[3].should eql("instance_id")
      keys.length.should eql(4)
    end
  end
end

describe "Address methods" do
  before(:each) do
    @fog_address = double("fog_address")
    @fog_address.stub(:id).and_return(1)
    @fog_address.stub(:ip).and_return("127.0.0.1")
    @fog_address.stub(:fixed_ip).and_return("127.0.0.2")
    @fog_address.stub(:instance_id).and_return(2)
    @connection = double("connection")
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::AddressHelper.new(@connection, @fog_address)

      disk.id.should eql(1)
      disk.ip.should eql("127.0.0.1")
      disk.fixed_ip.should eql("127.0.0.2")
      disk.instance_id.should eql(2)
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::AddressHelper.new(@connection)

      disk.id.should be_nil
      disk.ip.should be_nil
      disk.fixed_ip.should be_nil
      disk.instance_id.should be_nil
      disk.cstatus.message.should be_nil
      disk.cstatus.error_code.should eq(:success)
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::AddressHelper.new(@connection, @fog_address).to_hash()

      hash["id"].should eql(1)
      hash["ip"].should eql("127.0.0.1")
      hash["fixed_ip"].should eql("127.0.0.2")
      hash["instance_id"].should eql(2)
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_address = double("new_address")
      @new_address.stub(:id).and_return(909)
      @new_address.stub(:ip).and_return("127.1.1.1")
      @new_address.stub(:fixed_ip).and_return("127.2.2.2")
      @addresses = double("addresses")
      @addresses.stub(:create).and_return(@new_address)
      @compute = double("compute")
      @compute.stub(:addresses).and_return(@addresses)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      addy = HP::Cloud::AddressHelper.new(@connection)

      addy.save.should be_true

      addy.id.should eq(909)
      addy.ip.should eq("127.1.1.1")
      addy.fixed_ip.should eq("127.2.2.2")
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @addresses = double("addresses")
      @addresses.stub(:create).and_return(nil)
      @compute = double("compute")
      @compute.stub(:addresses).and_return(@addresses)
      @connection = double("connection")
      @connection.stub(:compute).and_return(@compute)
      addy = HP::Cloud::AddressHelper.new(@connection)

      addy.save.should be_false

      addy.id.should be_nil
      addy.ip.should be_nil
      addy.fixed_ip.should be_nil
      addy.cstatus.message.should eq("Error creating ip address")
      addy.cstatus.error_code.should eq(:general_error)
    end
  end
end
