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

  context "when we have garbage" do
    it "should throw exception" do
      lambda {
        HP::Cloud::TimeParser.parse("garbage")
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Error parsing time period: garbage")
      }
    end
  end

  context "when we have garbage" do
    it "should throw exception" do
      lambda {
        HP::Cloud::TimeParser.parse("1k")
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Error parsing time period: 1k")
      }
    end
  end
end
