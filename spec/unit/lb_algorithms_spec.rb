require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "LbAlgorithms" do
  context "name" do
    it "should return name" do
      LbAlgorithms.new.name.should eq("load balancer algorithm")
    end
  end

  context "items" do
    it "should return them all" do
      @items = [ "1", "2", "3" ]
      @service = double("service")
      @connection = double("connection")
      @service.stub(:algorithms).and_return(@items)
      @connection.stub(:lb).and_return(@service)
      Connection.stub(:instance).and_return(@connection)

      sot = LbAlgorithms.new

      sot.items.should eq(@items)
    end
  end

  context "matches" do
    it "should return name" do
      item = double("connection")
      item.stub(:name).and_return("nameo")
      item.stub(:id).and_return("ido")
      sot = LbAlgorithms.new

      sot.matches("nameo", item).should be_true
      sot.matches("ido", item).should be_false
      sot.matches("bogus", item).should be_false
    end
  end
end
