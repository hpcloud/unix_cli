require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Valid source" do
  before(:each) do
    @container = double("container")
    @directories = double("directories")
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
    Connection.instance.stub(:storage).and_return(@storage)
  end

  context "when remote file" do
    it "is real file true" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(":container/whatever.txt")

      to.valid_source().should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when local file" do
    it "is bogus file false" do
      @directories.stub(:get).and_return(nil)
      to = Resource.create(":bogus_container/whatever.txt")

      to.valid_source().should be_false

      to.error_string.should eq("You don't have a container 'bogus_container'.")
      to.error_code.should eq(:not_found)
    end
  end
end

describe "Set destination" do

  before(:each) do
    @container = double("container")
    @directories = double("directories")
    @directories.stub(:get).and_return(@container)
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
    Connection.instance.stub(:storage).and_return(@storage)
  end
  
  context "when remote directory empty" do
    it "valid destination true" do
      to = Resource.create(":container")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("file.txt")
    end
  end

  context "when remote file ends in slash" do
    it "valid destination true" do
      to = Resource.create(":container/directory/")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("directory/file.txt")
    end
  end

  context "when remote file rename" do
    it "valid destination true" do
      to = Resource.create(":container/directory/new.txt")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("directory/new.txt")
    end
  end
  
  context "when remote container missing" do
    it "valid destination true" do
      @directories.stub(:get).and_return(nil)
      to = Resource.create(":missing_container/directory/new.txt")
      from = Resource.create("file.txt")

      rc = to.set_destination(from)

      rc.should be_false
      to.error_string.should eq("You don't have a container 'missing_container'.")
      to.error_code.should eq(:not_found)
      to.destination.should be_nil
    end
  end
  
end
