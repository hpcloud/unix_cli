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

  context "when remote file" do
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

describe "Remote file open read write close" do
  context "when remote file" do
    it "everything does nothing" do
      res = Resource.create(":container/whatever.txt")

      res.open().should be_false
      res.read().should be_nil
      res.write("dkdkdkdkd").should be_false
      res.close().should be_false
    end
  end
end

describe "File copy" do
  before(:each) do
    @container = double("container")
    @directories = double("directories")
    @directories.stub(:get).and_return(@container)
    @get_object = double("get_object")
    @put_object = double("put_object")
    @storage = double("storage")
    @storage.stub(:get_object).and_return(@get_object)
    @storage.stub(:put_object).and_return(@put_object)
    @storage.stub(:directories).and_return(@directories)
    Connection.instance.stub(:storage).and_return(@storage)
  end

  context "when bogus local file source" do
    it "copy should return false" do
      src = Resource.create("spec/bogus/directory/")
      dest = Resource.create(":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source but bogus destination" do
    it "copy should return false" do
      @directories.stub(:get).and_return(nil)
      src = Resource.create("spec/fixtures/files/foo.txt")
      dest = Resource.create(":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file unreadable" do
    it "copy should return false" do
      Dir.mkdir('spec/tmp/unreadable') unless File.directory?('spec/tmp/unreadable')
      File.chmod(0000, 'spec/tmp/unreadable')
      src = Resource.create("spec/tmp/unreadable")
      dest = Resource.create(":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source" do
    it "copies the data" do
      src = Resource.create("spec/fixtures/files/foo.txt")
      dest = Resource.create(":container/destination.txt")

      dest.copy(src).should be_true
    end
  end

  context "when local file source and destination" do
    it "copies the data" do
      File.unlink("spec/tmp/output.txt") if File.exists?("spec/tmp/output.txt")
      src = Resource.create("spec/fixtures/files/foo.txt")
      dest = Resource.create("spec/tmp/output.txt")

      dest.copy(src).should be_true

      File.exists?("spec/tmp/output.txt").should be_true
      File.open("spec/tmp/output.txt").read().should eq("This is a foo file.")
    end
  end

  context "when remote file source" do
    it "copies the data" do
      src = Resource.create(":container/source.txt")
      dest = Resource.create("spec/tmp/result.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote file source and destination" do
    it "copies the data" do
      src = Resource.create(":container/source.txt")
      dest = Resource.create(":container/copy.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote files, but source does not exist" do
    it "fails" do
      @storage.stub(:put_object).and_raise(Fog::Storage::HP::NotFound)
      src = Resource.create(":container/source.txt")
      dest = Resource.create(":container/copy.txt")

      dest.copy(src).should be_false

      dest.error_string.should eq("The specified object does not exist.")
      dest.error_code.should eq(:not_found)
    end
  end
end

describe "Read directory" do
  before(:each) do
    @files = ["files/",
              "files/cantread.txt",
              "files/with space.txt",
              "files/foo.txt" ]
    @container = double("container")
    @container.stub(:files).and_return(@files)
    @directories = double("directories")
    @directories.stub(:get).and_return(@container)
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
    Connection.instance.stub(:storage).and_return(@storage)
  end

  context "when just a container" do
    it "gets all the files" do
      res = Resource.create(":container")
      ray = Array.new

      res.foreach{ |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/")
      ray[1].should eq(":container/files/cantread.txt")
      ray[2].should eq(":container/files/foo.txt")
      ray[3].should eq(":container/files/with space.txt")
      ray.length.should eq(4)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(":container/files/foo.txt")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(":container/.*/foo.*")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when no match" do
    it "gets nothing" do
      res = Resource.create(":container/foo")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray.length.should eq(0)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(":container/files/c")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/cantread.txt")
      ray.length.should eq(1)
    end
  end

end
