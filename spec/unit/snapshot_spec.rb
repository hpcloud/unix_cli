require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Snapshot keys" do
  context "when we get" do
    it "should have expected values" do
      keys = HP::Cloud::SnapshotHelper.get_keys()

      keys[0].should eql("id")
      keys[1].should eql("name")
      keys[2].should eql("volume")
      keys[3].should eql("size")
      keys[4].should eql("created")
      keys[5].should eql("status")
      keys[6].should eql("description")
      keys.length.should eql(7)
    end
  end
end

describe "Snapshot methods" do
  before(:each) do
    @fog_snapshot = double("fog_snapshot")
    @fog_snapshot.stub(:id).and_return(1)
    @fog_snapshot.stub(:name).and_return("MyDisk")
    @fog_snapshot.stub(:volume_id).and_return(908)
    @fog_snapshot.stub(:size).and_return(2)
    @fog_snapshot.stub(:created_at).and_return(Date.new(2011, 10, 31))
    @fog_snapshot.stub(:status).and_return("available")
    @fog_snapshot.stub(:description).and_return("My cool disk")
    @volume = double("volume")
    @volume.stub(:is_valid?).and_return(true)
    @volume.stub(:id).and_return(908)
    @volume.stub(:name).and_return("volley")
    @volumes = double("volumes")
    @volumes.stub(:get).and_return(@volume)
    Volumes.stub(:new).and_return(@volumes)
  end

  context "when given fog object" do
    it "should have expected values" do
      disk = HP::Cloud::SnapshotHelper.new(double("connection"), @fog_snapshot)

      disk.id.should eql(1)
      disk.name.should eql("MyDisk")
      disk.volume.should eql("volley")
      disk.size.should eql(2)
      disk.created.should eql(Date.new(2011, 10, 31))
      disk.status.should eql("available")
      disk.description.should eq("My cool disk")
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when given nothing" do
    it "should have expected values" do
      disk = HP::Cloud::SnapshotHelper.new(double("connection"))

      disk.id.should be_nil
      disk.name.should be_nil
      disk.volume.should be_nil
      disk.size.should be_nil
      disk.created.should be_nil
      disk.status.should be_nil
      disk.description.should be_nil
      disk.error_string.should be_nil
      disk.error_code.should be_nil
    end
  end

  context "when we convert to hash" do
    it "get all the expected values" do
      hash = HP::Cloud::SnapshotHelper.new(double("connection"), @fog_snapshot).to_hash()

      hash["id"].should eql(1)
      hash["name"].should eql("MyDisk")
      hash["volume"].should eql("volley")
      hash["size"].should eql(2)
      hash["created"].should eql(Date.new(2011, 10, 31))
      hash["status"].should eql("available")
      hash["description"].should eq("My cool disk")
    end
  end

  context "when we save successfully" do
    it "it is true and we get id" do
      @new_snapshot = double("new_snapshot")
      @new_snapshot.stub(:id).and_return(909)
      @snapshots = double("snapshots")
      @snapshots.stub(:create).and_return(@new_snapshot)
      @block = double("block")
      @block.stub(:snapshots).and_return(@snapshots)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      snappy = HP::Cloud::SnapshotHelper.new(@connection)
      snappy.name = 'lion'
      snappy.description = 'mt lion'
      snappy.set_volume(@volume.name)

      snappy.save.should be_true

      snappy.id.should eq(909)
    end
  end

  context "when save fails" do
    it "it is false and we get errors" do
      @snapshots = double("snapshots")
      @snapshots.stub(:create).and_return(nil)
      @block = double("block")
      @block.stub(:snapshots).and_return(@snapshots)
      @connection = double("connection")
      @connection.stub(:block).and_return(@block)
      snappy = HP::Cloud::SnapshotHelper.new(@connection)
      snappy.name = 'lion'
      snappy.description = 'mt lion'
      snappy.set_volume(@volume.name)

      snappy.save.should be_false

      snappy.id.should be_nil
      snappy.error_string.should eq("Error creating snapshot 'lion'")
      snappy.error_code.should eq(:general_error)
    end
  end
end
