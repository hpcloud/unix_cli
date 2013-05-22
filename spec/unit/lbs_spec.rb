require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Lbs" do
  before(:each) do
    @items = [ "1", "2", "3" ]
    @service = double("service")
    @connection = double("connection")
    @service.stub(:load_balancers).and_return(@items)
    @connection.stub(:lb).and_return(@service)
    Connection.stub(:instance).and_return(@connection)
  end

  context "name" do
    it "should return name" do
      Lbs.new.name.should eq("load balancer")
    end
  end

  context "items" do
    it "should return them all" do
      @items = [ "1", "2", "3" ]
      @service = double("service")
      @connection = double("connection")
      @service.stub(:load_balancers).and_return(@items)
      @connection.stub(:lb).and_return(@service)
      Connection.stub(:instance).and_return(@connection)

      sot = Lbs.new

      sot.items.should eq(@items)
    end
  end
end
