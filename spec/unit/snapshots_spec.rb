require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Snapshots getter" do
  def mock_snapshot(name)
    fog_snapshot = double(name)
    @id = 1 if @id.nil?
    fog_snapshot.stub(:id).and_return(@id.to_s)
    @id += 1
    fog_snapshot.stub(:name).and_return(name)
    fog_snapshot.stub(:volume).and_return("volley")
    fog_snapshot.stub(:volume_id).and_return(444)
    fog_snapshot.stub(:size).and_return(0)
    fog_snapshot.stub(:created_at).and_return(Date.new(2011, 10, 31))
    fog_snapshot.stub(:status).and_return("available")
    fog_snapshot.stub(:description).and_return("My cool disk")
    return fog_snapshot
  end

  before(:each) do
    SnapshotHelper.clear_cache
    @snapshots = [ mock_snapshot("snap1"), mock_snapshot("snap2"), mock_snapshot("snap3"), mock_snapshot("snap3") ]
    @block = double("block")
    @block.stub(:snapshots).and_return(@snapshots)

    @volume = double("volume")
    @volume.stub(:is_valid?).and_return(true)
    @volume.stub(:id).and_return(444)
    @volume.stub(:name).and_return("volley")
    @volumes = double("vvvolumes")
    @volumes.stub(:get).and_return(@volume)
    Volumes.stub(:new).and_return(@volumes)

    @compute = double("compute")
    @compute.stub(:servers).and_return([])
    @connection = double("connection")
    @connection.stub(:compute).and_return(@compute)
    @connection.stub(:block).and_return(@block)
    Connection.stub(:instance).and_return(@connection)
  end

  context "when we get with no arguments" do
    it "should return them all" do
      snapshots = Snapshots.new.get()

      snapshots[0].name.should eql("snap1")
      snapshots[1].name.should eql("snap2")
      snapshots[2].name.should eql("snap3")
      snapshots[3].name.should eql("snap3")
      snapshots.length.should eql(4)
    end
  end

  context "when we specify id" do
    it "should return them all" do
      snapshots = Snapshots.new.get(["3"])

      snapshots[0].name.should eql("snap3")
      snapshots[0].id.to_s.should eql("3")
      snapshots.length.should eql(1)
    end
  end

  context "when we specify name" do
    it "should return them all" do
      snapshots = Snapshots.new.get(["snap2"])

      snapshots[0].name.should eql("snap2")
      snapshots.length.should eql(1)
    end
  end

  context "when we specify a couple" do
    it "should return them all" do
      snapshots = Snapshots.new.get(["1", "snap2"])

      snapshots[0].name.should eql("snap1")
      snapshots[1].name.should eql("snap2")
      snapshots.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return both" do
      snapshots = Snapshots.new.get(["snap3"])

      snapshots[0].name.should eql("snap3")
      snapshots[1].name.should eql("snap3")
      snapshots.length.should eql(2)
    end
  end

  context "when we match multiple" do
    it "should return error" do
      snapshots = Snapshots.new.get(["snap3"], false)

      snapshots[0].is_valid?.should be_false
      snapshots[0].cstatus.error_code.should eq(:general_error)
      snapshots[0].cstatus.message.should eq("More than one snapshot matches 'snap3', use the id instead of name.")
      snapshots.length.should eql(1)
    end
  end

  context "when we fail to match" do
    it "should return error" do
      snapshots = Snapshots.new.get(["bogus"])

      snapshots[0].is_valid?.should be_false
      snapshots[0].cstatus.error_code.should eq(:not_found)
      snapshots[0].cstatus.message.should eq("Cannot find a snapshot matching 'bogus'.")
      snapshots.length.should eql(1)
    end
  end

  context "when check empty" do
    it "should return false" do
      Snapshots.new.empty?.should be_false
    end
  end
end
