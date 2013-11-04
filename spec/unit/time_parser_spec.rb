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

describe "TimeParser class" do

  context "when we have seconds" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse("1s").should eq(1)
      HP::Cloud::TimeParser.parse("10s").should eq(10)
      HP::Cloud::TimeParser.parse("100s").should eq(100)
      HP::Cloud::TimeParser.parse("1000s").should eq(1000)
    end
  end

  context "when we have minutes" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse("1m").should eq(60)
      HP::Cloud::TimeParser.parse("10m").should eq(600)
    end
  end

  context "when we have hours" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse("1h").should eq(3600)
      HP::Cloud::TimeParser.parse("10h").should eq(36000)
    end
  end

  context "when we have days" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse("1d").should eq(86400)
      HP::Cloud::TimeParser.parse("10d").should eq(864000)
    end
  end

  context "when we have days" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse("1d").should eq(86400)
      HP::Cloud::TimeParser.parse("10d").should eq(864000)
    end
  end

  context "when we have days" do
    it "should return seconds" do
      HP::Cloud::TimeParser.parse(nil).should eq(nil)
    end
  end

  context "when we have garbage" do
    it "should throw exception" do
      lambda {
        HP::Cloud::TimeParser.parse("garbage")
      }.should raise_error(Exception) {|e|
        e.to_s.should include("The expected time format contains value and unit like 2d for two days.  Supported units are s, m, h, or d")
      }
    end
  end

  context "when we have garbage" do
    it "should throw exception" do
      lambda {
        HP::Cloud::TimeParser.parse("1k")
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Unrecognized time unit k in 1k expected s, m, h, or d")
      }
    end
  end
end
