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
      
describe "Server getter" do
  def mock_server(name)
    fog_server = double("server")
    fog_server.stub(:id).and_return(1)
    fog_server.stub(:name).and_return(name)
    fog_server.stub(:flavor_id).and_return("chocolate")
    fog_server.stub(:image_id).and_return("122")
    fog_server.stub(:public_ip_address).and_return("10.0.0.1")
    fog_server.stub(:private_ip_address).and_return("172.1.1.1")
    fog_server.stub(:key_name).and_return("key")
    security_groups = [{"name" => "one"}, {"name" => "two"}]
    fog_server.stub(:security_groups).and_return(@security_groups)
    fog_server.stub(:created_at).and_return("today")
    fog_server.stub(:state).and_return("ACTIVE")
    fog_server.stub(:tenant_id).and_return("10ants")
    fog_server.stub(:network_name).and_return("netti")
    fog_server.stub(:addresses).and_return(nil)
    fog_server.stub(:metadata).and_return([])
    return fog_server
  end

  before(:each) do
    @all = [ mock_server("Hal"), mock_server("Skynet"), mock_server("Matrix") ]
    @servers = double("servers")
    @servers.stub(:all).and_return(@all)
    @compute = double("compute")
    @compute.stub(:servers).and_return(@servers)
    Connection.instance.stub(:compute).and_return(@compute)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      servers = HP::Cloud::Servers.new.get()

      servers[0].name.should eql("Hal")
      servers[1].name.should eql("Skynet")
      servers[2].name.should eql("Matrix")
      servers.length.should eql(3)
    end
  end 
      
      
  context "when check empty" do
    it "should return false" do
      Servers.new.empty?.should be_false
    end
  end 
end
