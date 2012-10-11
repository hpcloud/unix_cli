require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Valid source" do
  before(:each) do
    @container = double("container")
    @directories = double("directories")
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
  end

  context "when remote file" do
    it "is real file true" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(@storage, ":container/whatever.txt")

      to.valid_source().should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when remote file" do
    it "is bogus file false" do
      @directories.stub(:get).and_return(nil)
      to = Resource.create(@storage, ":bogus_container/whatever.txt")

      to.valid_source().should be_false

      to.error_string.should eq("You don't have a container 'bogus_container'.")
      to.error_code.should eq(:not_found)
    end
  end
end

describe "Valid destination" do
  before(:each) do
    @container = double("container")
    @directories = double("directories")
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
  end

  context "when remote file" do
    it "and source is file" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(@storage, ":container/whatever.txt")
      src = double("source")
      src.stub(:isMulti).and_return(false)

      to.valid_destination(src).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when remote directory" do
    it "and source is file" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(@storage, ":container/whatever/")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when remote container" do
    it "and source is file" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(@storage, ":container")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_true

      to.error_string.should be_nil
      to.error_code.should be_nil
    end
  end

  context "when remote file" do
    it "and source is directory" do
      @directories.stub(:get).and_return(@container)
      to = Resource.create(@storage, ":container/whatever.txt")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_false

      to.error_string.should eq("Invalid target for directory/multi-file copy ':container/whatever.txt'.")
      to.error_code.should eq(:incorrect_usage)
    end
  end

  context "when remote file" do
    it "is bogus file false" do
      @directories.stub(:get).and_return(nil)
      to = Resource.create(@storage, ":bogus_container/whatever.txt")

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
  end
  
  context "when remote directory empty" do
    it "valid destination true" do
      to = Resource.create(@storage, ":container")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("file.txt")
    end
  end

  context "when remote file ends in slash" do
    it "valid destination true" do
      to = Resource.create(@storage, ":container/directory/")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("directory/file.txt")
    end
  end

  context "when remote file rename" do
    it "valid destination true" do
      to = Resource.create(@storage, ":container/directory/new.txt")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.error_string.should be_nil
      to.error_code.should be_nil
      to.destination.should eq("directory/new.txt")
    end
  end
  
  context "when remote container missing" do
    it "valid destination true" do
      @directories.stub(:get).and_return(nil)
      to = Resource.create(@storage, ":missing_container/directory/new.txt")

      rc = to.set_destination("file.txt")

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
      res = Resource.create(@storage, ":container/whatever.txt")

      res.open().should be_false
      res.read().should be_nil
      res.write("dkdkdkdkd").should be_false
      res.close().should be_false
    end
  end
end

describe "File copy" do
  before(:each) do
    @sourcetxt = double("sourcetxt")
    @sourcetxt.stub(:key).and_return("source.txt")
    @files = [@sourcetxt]
    @container = double("container")
    @container.stub(:files).and_return(@files)
    @directories = double("directories")
    @directories.stub(:get).and_return(@container)
    @get_object = double("get_object")
    @put_object = double("put_object")
    @headers = { "Content-Length" => 9 }
    @head = double("head")
    @head.stub(:headers).and_return(@headers)
    @storage = double("storage")
    @storage.stub(:head_object).and_return(@head)
    @storage.stub(:get_object).and_return(@get_object)
    @storage.stub(:put_object).and_return(@put_object)
    @storage.stub(:directories).and_return(@directories)
  end

  context "when bogus local file source" do
    it "copy should return false" do
      src = Resource.create(@storage, "spec/bogus/directory/")
      dest = Resource.create(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source but bogus destination" do
    it "copy should return false" do
      @directories.stub(:get).and_return(nil)
      src = Resource.create(@storage, "spec/fixtures/files/foo.txt")
      dest = Resource.create(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file unreadable" do
    it "copy should return false" do
      Dir.mkdir('spec/tmp/unreadable') unless File.directory?('spec/tmp/unreadable')
      File.chmod(0000, 'spec/tmp/unreadable')
      src = Resource.create(@storage, "spec/tmp/unreadable")
      dest = Resource.create(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source to remote destination" do
    it "copies the data" do
      src = Resource.create(@storage, "spec/fixtures/files/foo.txt")
      dest = Resource.create(@storage, ":container/destination.txt")

      dest.copy(src).should be_true
    end
  end

  context "when local file source and destination" do
    it "copies the data" do
      File.unlink("spec/tmp/output.txt") if File.exists?("spec/tmp/output.txt")
      src = Resource.create(@storage, "spec/fixtures/files/foo.txt")
      dest = Resource.create(@storage, "spec/tmp/output.txt")

      dest.copy(src).should be_true

      File.exists?("spec/tmp/output.txt").should be_true
      File.open("spec/tmp/output.txt").read().should eq("This is a foo file.")
      File.unlink("spec/tmp/output.txt") if File.exists?("spec/tmp/output.txt")
    end
  end

  context "when remote file source to local destination" do
    it "copies the data" do
      src = Resource.create(@storage, ":container/source.txt")
      dest = Resource.create(@storage, "spec/tmp/result.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote file source and destination" do
    it "copies the data" do
      src = Resource.create(@storage, ":container/source.txt")
      dest = Resource.create(@storage, ":container/copy.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote files, but source does not exist" do
    it "fails" do
      @storage.stub(:put_object).and_raise(Fog::Storage::HP::NotFound)
      src = Resource.create(@storage, ":container/source.txt")
      dest = Resource.create(@storage, ":container/copy.txt")

      dest.copy(src).should be_false

      dest.error_string.should eq("The specified object does not exist.")
      dest.error_code.should eq(:not_found)
    end
  end
end

describe "Read directory" do
  before(:each) do
    @cantread = double("cantread")
    @cantread.stub(:key).and_return("files/cantread.txt")
    @withspace = double("withspace")
    @withspace.stub(:key).and_return("files/subdir/with space.txt")
    @footxt = double("footxt")
    @footxt.stub(:key).and_return("files/foo.txt")
    @files = [@cantread,
              @withspace,
              @footxt ]
    @container = double("container")
    @container.stub(:files).and_return(@files)
    @directories = double("directories")
    @directories.stub(:get).and_return(@container)
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
  end

  context "when just a container" do
    it "gets all the files" do
      res = Resource.create(@storage, ":container")
      ray = Array.new

      res.foreach{ |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/cantread.txt")
      ray[1].should eq(":container/files/foo.txt")
      ray[2].should eq(":container/files/subdir/with space.txt")
      ray.length.should eq(3)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(@storage, ":container/files/foo.txt")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = Resource.create(@storage, ":container/.*/foo.*")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when no match" do
    it "gets nothing" do
      res = Resource.create(@storage, ":container/foo")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray.length.should eq(0)
    end
  end

  context "when partial file name" do
    it "gets just the file" do
      res = Resource.create(@storage, ":container/files/cantread")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray.length.should eq(0)
    end
  end

  context "when subdir" do
    it "gets just subdir" do
      res = Resource.create(@storage, ":container/files/subdir/")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/subdir/with space.txt")
      ray.length.should eq(1)
    end
  end

end

describe "Remote resource get size" do

  before(:each) do
    @headers = { "Content-Length" => 233 }
    @head = double("head")
    @head.stub(:headers).and_return(@headers)
    @storage = double("storage")
    @storage.stub(:head_object).and_return(@head)
  end

  context "get valid size" do
    it "correctly" do
      res = Resource.create(@storage, ":container/files/subdir/")

      res.get_size().should eq(233)
    end
  end

  context "get valid size" do
    it "new size" do
      @head.stub(:headers).and_return({"Content-Length" => 502 })
      res = Resource.create(@storage, ":container/files/subdir/")

      res.get_size().should eq(502)
    end
  end

  context "no content-length" do
    it "gets zero" do
      @head.stub(:headers).and_return({})
      res = Resource.create(@storage, ":container/files/subdir/")

      res.get_size().should eq(0)
    end
  end

  context "head object fails" do
    it "still gets zero" do
      @storage.stub(:head_object).and_return(nil)
      res = Resource.create(@storage, ":container/files/subdir/")

      res.get_size().should eq(0)
    end
  end

  context "remove succeeds" do
    it "returns true" do
      @file = double("file")
      @file.should_receive(:destroy).and_return(true)
      @files = double("files")
      @files.stub(:head).and_return(@file)
      @directory = double("directory")
      @directory.stub(:files).and_return(@files)
      @directories = double("directories")
      @directories.stub(:head).and_return(@directory)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.remove(false).should be_true
    end
  end

  context "remove container not found" do
    it "returns false and sets error" do
      @directories = double("directories")
      @directories.stub(:head).and_return(nil)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.error_string.should eq("You don't have a container named ':container'.")
      res.error_code.should eq(:not_found)
    end
  end

  context "remove file not found" do
    it "returns false and sets error" do
      @files = double("files")
      @files.stub(:head).and_return(nil)
      @directory = double("directory")
      @directory.stub(:files).and_return(@files)
      @directories = double("directories")
      @directories.stub(:head).and_return(@directory)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.error_string.should eq("You don't have an object named ':container/files/river.txt'.")
      res.error_code.should eq(:not_found)
    end
  end

  context "tempurl succeeds" do
    it "return true" do
      @file = double("file")
      @file.should_receive(:temp_signed_url).and_return("http://woot.com/")
      @files = double("files")
      @files.stub(:get).and_return(@file)
      @directory = double("directory")
      @directory.stub(:files).and_return(@files)
      @directories = double("directories")
      @directories.stub(:head).and_return(@directory)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.tempurl(1212).should eq("http://woot.com/")
    end
  end

  context "tempurl container not found" do
    it "returns false and sets error" do
      @directories = double("directories")
      @directories.stub(:head).and_return(nil)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.tempurl(1212).should be_nil

      res.error_string.should eq("Cannot find container ':container'.")
      res.error_code.should eq(:not_found)
    end
  end

  context "temp url file not found" do
    it "returns false and sets error" do
      @files = double("files")
      @files.stub(:get).and_return(nil)
      @directory = double("directory")
      @directory.stub(:files).and_return(@files)
      @directories = double("directories")
      @directories.stub(:head).and_return(@directory)
      @storage.stub(:directories).and_return(@directories)
      res = Resource.create(@storage, ":container/files/river.txt")

      res.tempurl(1212).should be_nil

      res.error_string.should eq("Cannot find object named ':container/files/river.txt'.")
      res.error_code.should eq(:not_found)
    end
  end
end
