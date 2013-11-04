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

describe "FogCollection" do
  def mock_lb_algorithm(name)
    fog_lb_algorithm = double(name)
    fog_lb_algorithm.stub(:name).and_return(name)
    return fog_lb_algorithm
  end

  before(:each) do
    @lb_algorithms = [ mock_lb_algorithm("sot1"), mock_lb_algorithm("sot2"), mock_lb_algorithm("sot3"), mock_lb_algorithm("sot3") ]
    @lb = double("lb")
    @lb.stub(:algorithms).and_return(@lb_algorithms)
    @connection = double("connection")
    @connection.stub(:lb).and_return(@lb)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      lb_algorithms = LbAlgorithms.new.get()

      lb_algorithms[0].name.should eql("sot1")
      lb_algorithms[1].name.should eql("sot2")
      lb_algorithms[2].name.should eql("sot3")
      lb_algorithms[3].name.should eql("sot3")
      lb_algorithms.length.should eql(4)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      lb_algorithms = LbAlgorithms.new.get(["sot2"])

      lb_algorithms[0].name.should eql("sot2")
      lb_algorithms.length.should eql(1)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      lb_algorithms = LbAlgorithms.new.get(["sot3"])

      lb_algorithms[0].name.should eql("sot3")
      lb_algorithms[1].name.should eql("sot3")
      lb_algorithms.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      lambda {
        LbAlgorithms.new.get(["sot3"], false)
      }.should raise_error(HP::Cloud::Exceptions::General) {|e|
        e.to_s.should eq("More than one load balancer algorithm matches 'sot3', use the id instead of name.")
      }
    end
  end

  context "when we fail to match" do
    it "should return error" do
      lambda {
        LbAlgorithms.new.get(["bogus"])
      }.should raise_error(HP::Cloud::Exceptions::NotFound) {|e|
        e.to_s.should eq("Cannot find a load balancer algorithm matching 'bogus'.")
      }
    end
  end

  context "when check empty" do
    it "should return false" do
      LbAlgorithms.new.empty?.should be_false
    end
  end

  context "when check empty" do
    it "should return false" do
      lambda {
        LbAlgorithms.new.unique("sot1")
      }.should raise_error(HP::Cloud::Exceptions::General) {|e|
        e.to_s.should eq("A load balancer algorithm with the name 'sot1' already exists")
      }
      LbAlgorithms.new.unique("noob").should be_nil
    end
  end
end
