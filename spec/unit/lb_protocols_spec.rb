require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "LbProtocols" do
  context "name" do
    it "should return name" do
      LbProtocols.new.name.should eq("load balancer protocol")
    end
  end

  context "items" do
    it "should return them all" do
      @items = [ "1", "2", "3" ]
      @service = double("service")
      @connection = double("connection")
      @service.stub(:protocols).and_return(@items)
      @connection.stub(:lb).and_return(@service)
      Connection.stub(:instance).and_return(@connection)

      sot = LbProtocols.new

      sot.items.should eq(@items)
    end
  end
end
