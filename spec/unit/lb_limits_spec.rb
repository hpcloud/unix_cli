require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "LbLimits" do
  context "name" do
    it "should return name" do
      LbLimits.new.name.should eq("load balancer limit")
    end
  end

  context "items" do
    it "should return them all" do
      @items = [ "1", "2", "3" ]
      @service = double("service")
      @connection = double("connection")
      @service.stub(:limits).and_return(@items)
      @connection.stub(:lb).and_return(@service)
      Connection.stub(:instance).and_return(@connection)

      sot = LbLimits.new

      sot.items.should eq(@items)
    end
  end

  context "matches" do
    it "should return name" do
      item = double("connection")
      item.stub(:name).and_return("nameo")
      item.stub(:id).and_return("ido")
      sot = LbLimits.new

      sot.matches("nameo", item).should be_true
      sot.matches("ido", item).should be_true
      sot.matches("bogus", item).should be_true
    end
  end
end
