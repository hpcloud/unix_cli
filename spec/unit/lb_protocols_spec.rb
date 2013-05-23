require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "LbProtocols" do
  before(:each) do
    @items = [ "1", "2", "3" ]
    @service = double("service")
    @connection = double("connection")
    @service.stub(:protocols).and_return(@items)
    @connection.stub(:lb).and_return(@service)
    Connection.stub(:instance).and_return(@connection)
  end

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

  context "matches" do
    it "should return name" do
      item = double("item")
      item.stub(:name).and_return("nameo")
      item.stub(:id).and_return("ido")
      sot = LbProtocols.new

      sot.matches("nameo", item).should be_true
      sot.matches("ido", item).should be_false
      sot.matches("bogus", item).should be_false
    end
  end
end
