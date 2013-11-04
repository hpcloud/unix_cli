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

describe "Subnet keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::SubnetHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("network_id")
      keys[3].should eql("cidr")
      keys[4].should eql("nameservers")
      keys[5].should eql("routes")
      keys[6].should eql("gateway")
      keys[7].should eql("dhcp")
      keys.length.should eql(8)
    end
  end
end

describe "Subnet methods" do
  before(:each) do
    @fog_subnet = double("fog_subnet")
    @fog_subnet.stub(:id).and_return(1)
    @fog_subnet.stub(:name).and_return("MySubnet")
    @fog_subnet.stub(:tenant_id).and_return("234")
    @fog_subnet.stub(:network_id).and_return(222)
    @fog_subnet.stub(:cidr).and_return("127.0.0.1/1")
    @fog_subnet.stub(:ip_version).and_return(4)
    @fog_subnet.stub(:dns_nameservers).and_return(222323)
    @fog_subnet.stub(:allocation_pools).and_return([])
    @fog_subnet.stub(:host_routes).and_return([])
    @fog_subnet.stub(:gateway_ip).and_return("127.0.0.1")
    @fog_subnet.stub(:enable_dhcp).and_return(true)
  end

  context "when given fog object" do
    it "should have expected values" do
      sot = HP::Cloud::SubnetHelper.new(double("connection"), @fog_subnet)

      sot.id.should eql(1)
      sot.name.should eql("MySubnet")
      sot.tenant_id.should eql("234")
      sot.network_id.should eql(222)
      sot.cidr.should eql("127.0.0.1/1")
      sot.ip_version.should eql(4)
      sot.dns_nameservers.should eql(222323)
      sot.allocation_pools.should eql([])
      sot.host_routes.should eql([])
      sot.gateway.should eql("127.0.0.1")
      sot.dhcp.should eql(true)
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      sot = HP::Cloud::SubnetHelper.new(double("connection"))

      sot.id.should be_nil
      sot.name.should be_nil
      sot.tenant_id.should be_nil
      sot.network_id.should be_nil
      sot.cidr.should be_nil
      sot.ip_version.should be_nil
      sot.dns_nameservers.should be_nil
      sot.allocation_pools.should be_nil
      sot.host_routes.should be_nil
      sot.gateway.should be_nil
      sot.dhcp.should be_nil
      sot.cstatus.message.should be_nil
      sot.cstatus.error_code.should eq(:success)
    end
  end

  context "Subnet set_cidr" do
    it "get all the expected values" do
      connection = double("connection")
      sot = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sot.set_cidr("127.0.0.1").should be_true
      sot.set_cidr("127.0.0.1/24").should be_true
      sot.set_cidr("127.0.0.1/x").should be_false
      sot.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.1/x")
      sot.set_cidr("127.0.0.999/24").should be_false
      sot.cstatus.to_s.should eq("Invalid CIDR value 127.0.0.999/24")
    end
  end

  context "Subnet set_ip_version" do
    it "get all the expected values" do
      connection = double("connection")
      sot = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sot.set_ip_version("4").should be_true
      sot.set_ip_version("6").should be_true
      sot.set_ip_version(6).should be_true
      sot.set_ip_version("5").should be_false
      sot.cstatus.to_s.should eq("Invalid IP version '5'")
    end
  end

  context "Subnet set_dns_nameservers" do
    it "get all the expected values" do
      connection = double("connection")
      sot = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sot.set_dns_nameservers("10.1.1.1,10.2.2.2").should be_true
      sot.dns_nameservers.should eq(["10.1.1.1","10.2.2.2"])
      sot.set_dns_nameservers("10.1.1.1").should be_true
      sot.dns_nameservers.should eq(["10.1.1.1"])
      sot.set_dns_nameservers("10.1.1").should be_false
      sot.cstatus.to_s.should eq("Invalid DNS nameserver '10.1.1' must be comma separated list of IPs")
    end
  end

  context "Subnet set_host_routes" do
    it "get all the expected values" do
      connection = double("connection")
      sot = HP::Cloud::SubnetHelper.new(connection, @fog_subnet)
      sot.set_host_routes("10.1.1.1,100.1.1.1;10.2.2.2,100.2.2.2").should be_true
      sot.host_routes.should eq([{"destination"=>"10.1.1.1", "nexthop"=>"100.1.1.1"}, {"destination"=>"10.2.2.2", "nexthop"=>"100.2.2.2"}])
      sot.set_host_routes("10.1.1.1,100.1.1.1").should be_true
      sot.host_routes.should eq([{"destination"=>"10.1.1.1", "nexthop"=>"100.1.1.1"}])
      sot.set_host_routes("10.1.1.1;10.2.2.2").should be_false
      sot.cstatus.to_s.should eq("Invalid host routes '10.1.1.1;10.2.2.2' must be semicolon separated list of destination,nexthop")
      sot.set_host_routes("10.1.1.1").should be_false
      sot.cstatus.to_s.should eq("Invalid host routes '10.1.1.1' must be semicolon separated list of destination,nexthop")
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::SubnetHelper.new(double("connection"), @fog_subnet).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MySubnet")
      hash["tenant_id"].should eql("234")
      hash["network_id"].should eq(222)
      hash["cidr"].should eq("127.0.0.1/1")
      hash["ip_version"].should eq(4)
      hash["dns_nameservers"].should eq(222323)
      hash["allocation_pools"].should eq([])
      hash["host_routes"].should eq([])
      hash["gateway"].should eq("127.0.0.1")
      hash["dhcp"].should be_true
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_subnet = {"subnet"=>{"id"=>909}}
      @resposote = double("resposote")
      @resposote.stub(:body).and_return(@new_subnet)
      @network = double("network")
      @network.stub(:create_subnet).and_return(@resposote)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::SubnetHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100
      sot.network_id = 2222323
      sot.cidr = "127.0.0.1"
      sot.ip_version = 6
      sot.dns_nameservers = 2222
      sot.allocation_pools = [123,333]
      sot.host_routes = [123,333]
      sot.gateway = "127.0.0.2"
      sot.dhcp = true

      sot.save.should be_true

      sot.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @network = double("network")
      @network.stub(:create_subnet).and_return(nil)
      @connection = double("connection")
      @connection.stub(:network).and_return(@network)
      sot = HP::Cloud::SubnetHelper.new(@connection)
      sot.name = 'quantum'
      sot.tenant_id = 100

      sot.save.should be_false

      sot.id.should be_nil
      sot.cstatus.message.should eq("Error creating subnet 'quantum'")
      sot.cstatus.error_code.should eq(:general_error)
    end
  end
end
