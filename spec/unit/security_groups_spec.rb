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

describe "SecurityGroups getter" do
  def mock_security_group(secg)
    fog_security_group = double(secg)
    @id = 1 if @id.nil?
    fog_security_group.stub(:id).and_return(@id.to_s) 
    @id += 1
    fog_security_group.stub(:name).and_return(secg)
    fog_security_group.stub(:description).and_return("description:" + secg)
    fog_security_group.stub(:tenant_id).and_return("4444")
    return fog_security_group
  end

  before(:each) do
    @security_groups = [ mock_security_group("secg1"), mock_security_group("secg2"), mock_security_group("secg3"), mock_security_group("secg3") ]

    @network = double("network")
    @network.stub(:security_groups).and_return(@security_groups)
    @connection = double("connection")
    @connection.stub(:network).and_return(@network)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      security_groups = SecurityGroups.new.get()

      security_groups[0].name.should eql("secg1")
      security_groups[1].name.should eql("secg2")
      security_groups[2].name.should eql("secg3")
      security_groups[3].name.should eql("secg3")
      security_groups.length.should eql(4)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      security_groups = SecurityGroups.new.get(["secg2"])

      security_groups[0].name.should eql("secg2")
      security_groups.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      security_groups = SecurityGroups.new.get(["secg1", "secg2"])

      security_groups[0].name.should eql("secg1")
      security_groups[1].name.should eql("secg2")
      security_groups.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      security_groups = SecurityGroups.new.get(["secg3"])

      security_groups[0].name.should eql("secg3")
      security_groups[1].name.should eql("secg3")
      security_groups.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      security_groups = SecurityGroups.new.get(["secg3"], false)

      security_groups[0].is_valid?.should be_false
      security_groups[0].cstatus.error_code.should eq(:general_error)
      security_groups[0].cstatus.message.should eq("More than one security group matches 'secg3', use the id instead of name.")
      security_groups.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      security_groups = SecurityGroups.new.get(["bogus"])

      security_groups[0].is_valid?.should be_false
      security_groups[0].cstatus.error_code.should eq(:not_found)
      security_groups[0].cstatus.message.should eq("Cannot find a security group matching 'bogus'.")
      security_groups.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      SecurityGroups.new.empty?.should be_false
    end
  end
end
