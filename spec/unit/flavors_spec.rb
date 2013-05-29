require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Flavors" do
  before(:each) do
    @items = [ "1", "2", "3" ]
    @service = double("service")
    @connection = double("connection")
    @service.stub(:flavors).and_return(@items)
    @connection.stub(:compute).and_return(@service)
    Connection.stub(:instance).and_return(@connection)
  end

  context "name" do
    it "should return name" do
      Flavors.new.name.should eq("flavor")
    end
  end

  context "items" do
    it "should return them all" do
      sot = Flavors.new

      sot.items.should eq(@items)
    end
  end

  context "matches" do
    it "should return name" do
      item = double("item")
      item.stub(:name).and_return("standard.large")
      item.stub(:id).and_return("ido")
      sot = Flavors.new

      sot.matches("standard.large", item).should be_true
      sot.matches("large", item).should be_true
      sot.matches("ido", item).should be_true
      sot.matches("standard", item).should be_false
    end
  end
end
