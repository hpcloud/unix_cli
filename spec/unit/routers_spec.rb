require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Routers" do
  before(:each) do
    @items = [ "1", "2", "3" ]
    @service = double("service")
    @connection = double("connection")
    @service.stub(:routers).and_return(@items)
    @connection.stub(:network).and_return(@service)
    Connection.stub(:instance).and_return(@connection)
  end

  context "name" do
    it "should return name" do
      Routers.new.name.should eq("router")
    end
  end

  context "items" do
    it "should return them all" do
      sot = Routers.new

      sot.items.should eq(@items)
    end
  end
end
