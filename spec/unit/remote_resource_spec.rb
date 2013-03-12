require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

def mock_it(files = nil)
    @file = double("file.txt")
    @file.stub(:get)
    files = [ @file ] if files.nil?
    @files = files
    @directory = double("directory")
    @directory.stub(:files).and_return(@files)
    @directory.stub(:bytes).and_return(123)
    @directory.stub(:count).and_return(files.length)
    @directory.stub(:synckey).and_return(nil)
    @directory.stub(:syncto).and_return(nil)
    @directory.stub(:grant).and_return(true)
    @directory.stub(:revoke).and_return(true)
    @directory.stub(:save).and_return(true)
    @directories = double("directories")
    @directories.stub(:get).and_return(@directory)
    @directories.stub(:head).and_return(@directory)
    @get_object = double("get_object")
    @put_object = double("put_object")
    @headers = { "Content-Length" => 9 }
    @head = double("head")
    @head.stub(:headers).and_return(@headers)
    @storage = double("storage")
    @storage.stub(:directories).and_return(@directories)
    @storage.stub(:head_object).and_return(@head)
    @storage.stub(:get_object).and_return(@get_object)
    @storage.stub(:put_object).and_return(@put_object)
    result = double("result")
    result.stub(:headers).and_return({'X-Container-Object-Count' => @files.length})
    result.stub(:body).and_return(@files)
    @storage.stub(:get_container).and_return(result)
    return @storage
end

def mock_file(filename)
  return { 'name' => filename,
           'hash' => "123123123123123",
           'bytes' => "234",
           'content_type' => "text"
         }
end

describe "Valid source" do
  before(:each) do
    @storage = mock_it
  end

  context "when remote file" do
    it "is real file true" do
      to = ResourceFactory.create_any(@storage, ":container/whatever.txt")

      to.valid_source().should be_true

      to.cstatus.is_success?.should be_true
    end
  end

  context "when remote file" do
    it "is bogus file false" do
      @directories.stub(:head).and_return(nil)
      to = ResourceFactory.create_any(@storage, ":bogus_container/whatever.txt")

      to.valid_source().should be_false

      to.cstatus.message.should eq("Cannot find container ':bogus_container'.")
      to.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "Valid destination" do
  before(:each) do
    @storage = mock_it
  end

  context "when remote file" do
    it "and source is file" do
      to = ResourceFactory.create_any(@storage, ":container/whatever.txt")
      src = double("source")
      src.stub(:isMulti).and_return(false)

      to.valid_destination(src).should be_true

      to.cstatus.is_success?.should be_true
    end
  end

  context "when remote directory" do
    it "and source is file" do
      to = ResourceFactory.create_any(@storage, ":container/whatever/")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_true

      to.cstatus.is_success?.should be_true
    end
  end

  context "when remote container" do
    it "and source is file" do
      to = ResourceFactory.create_any(@storage, ":container")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_true

      to.cstatus.is_success?.should be_true
    end
  end

  context "when remote file" do
    it "and source is directory" do
      to = ResourceFactory.create_any(@storage, ":container/whatever.txt")
      src = double("source")
      src.stub(:isMulti).and_return(true)

      to.valid_destination(src).should be_false

      to.cstatus.message.should eq("Invalid target for directory/multi-file copy ':container/whatever.txt'.")
      to.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "when remote file" do
    it "is bogus file false" do
      @directories.stub(:head).and_return(nil)
      to = ResourceFactory.create_any(@storage, ":bogus_container/whatever.txt")

      to.valid_source().should be_false

      to.cstatus.message.should eq("Cannot find container ':bogus_container'.")
      to.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "Set destination" do

  before(:each) do
    @storage = mock_it
  end
  
  context "when remote directory empty" do
    it "valid destination true" do
      to = ResourceFactory.create_any(@storage, ":container")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.cstatus.is_success?.should be_true
      to.destination.should eq("file.txt")
    end
  end

  context "when remote file ends in slash" do
    it "valid destination true" do
      to = ResourceFactory.create_any(@storage, ":container/directory/")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.cstatus.is_success?.should be_true
      to.destination.should eq("directory/file.txt")
    end
  end

  context "when remote file rename" do
    it "valid destination true" do
      to = ResourceFactory.create_any(@storage, ":container/directory/new.txt")

      rc = to.set_destination("file.txt")

      rc.should be_true
      to.cstatus.is_success?.should be_true
      to.destination.should eq("directory/new.txt")
    end
  end
  
  context "when remote container missing" do
    it "valid destination true" do
      @directories.stub(:head).and_return(nil)
      to = ResourceFactory.create_any(@storage, ":missing_container/directory/new.txt")

      rc = to.set_destination("file.txt")

      rc.should be_false
      to.cstatus.message.should eq("Cannot find container ':missing_container'.")
      to.cstatus.error_code.should eq(:not_found)
      to.destination.should be_nil
    end
  end
  
end

describe "Remote file open read write close" do
  context "when remote file" do
    it "everything does nothing" do
      @storage = double("storage")
      @storage.stub(:get_object).and_yield("chunk", 0, 0)
      @storage.stub(:put_object).and_return(true)

      res = ResourceFactory.create_any(@storage, ":container/whatever.txt")

      res.open().should be_true
      res.read() { |chunk| chunk.should eq("chunk") }
      res.write("dkdkdkdkd").should be_true
      res.close().should be_true
    end
  end
end

describe "File copy" do
  before(:each) do
    @storage = mock_it([mock_file("source.txt")])
  end

  context "when bogus local file source" do
    it "copy should return false" do
      src = ResourceFactory.create_any(@storage, "spec/bogus/directory/")
      dest = ResourceFactory.create_any(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source but bogus destination" do
    it "copy should return false" do
      @directories.stub(:head).and_return(nil)
      src = ResourceFactory.create_any(@storage, "spec/fixtures/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file unreadable" do
    it "copy should return false" do
      Dir.mkdir('spec/tmp/unreadable') unless File.directory?('spec/tmp/unreadable')
      File.chmod(0000, 'spec/tmp/unreadable')
      src = ResourceFactory.create_any(@storage, "spec/tmp/unreadable")
      dest = ResourceFactory.create_any(@storage, ":container/destination.txt")

      dest.copy(src).should be_false
    end
  end

  context "when local file source to remote destination" do
    it "copies the data" do
      src = ResourceFactory.create_any(@storage, "spec/fixtures/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, ":container/destination.txt")

      dest.copy(src).should be_true
    end
  end

  context "when local file source and destination" do
    it "copies the data" do
      File.unlink("spec/tmp/output.txt") if File.exists?("spec/tmp/output.txt")
      src = ResourceFactory.create_any(@storage, "spec/fixtures/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, "spec/tmp/output.txt")

      dest.copy(src).should be_true

      File.exists?("spec/tmp/output.txt").should be_true
      File.open("spec/tmp/output.txt").read().should eq("This is a foo file.")
      File.unlink("spec/tmp/output.txt") if File.exists?("spec/tmp/output.txt")
    end
  end

  context "when remote file source to local destination" do
    it "copies the data" do
      src = ResourceFactory.create_any(@storage, ":container/source.txt")
      dest = ResourceFactory.create_any(@storage, "spec/tmp/result.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote file source and destination" do
    it "copies the data" do
      src = ResourceFactory.create_any(@storage, ":container/source.txt")
      dest = ResourceFactory.create_any(@storage, ":container/copy.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote files, but source does not exist" do
    it "fails" do
      @storage.stub(:put_object).and_raise(Fog::Storage::HP::NotFound)
      src = ResourceFactory.create_any(@storage, ":container/source.txt")
      dest = ResourceFactory.create_any(@storage, ":container/copy.txt")

      dest.copy(src).should be_false

      dest.cstatus.message.should eq("The specified object does not exist.")
      dest.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "Read directory" do
  before(:each) do
    @files = [ mock_file("files/cantread.txt"),
               mock_file("files/subdir/with space.txt"),
               mock_file("files/foo.txt") ]
    @storage = mock_it(@files)
  end

  context "when just a container" do
    it "gets all the files" do
      res = ResourceFactory.create_any(@storage, ":container")
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
      res = ResourceFactory.create_any(@storage, ":container/files/foo.txt")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when file" do
    it "gets just the file" do
      res = ResourceFactory.create_any(@storage, ":container/.*/foo.*")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq(":container/files/foo.txt")
      ray.length.should eq(1)
    end
  end

  context "when no match" do
    it "gets nothing" do
      res = ResourceFactory.create_any(@storage, ":container/foo")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray.length.should eq(0)
    end
  end

  context "when partial file name" do
    it "gets just the file" do
      res = ResourceFactory.create_any(@storage, ":container/files/cantread")
      ray = Array.new

      res.foreach { |x| ray.push(x.fname) }

      ray.sort!
      ray.length.should eq(0)
    end
  end

  context "when subdir" do
    it "gets just subdir" do
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")
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
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")

      res.get_size().should eq(233)
    end
  end

  context "get valid size" do
    it "new size" do
      @head.stub(:headers).and_return({"Content-Length" => 502 })
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")

      res.get_size().should eq(502)
    end
  end

  context "no content-length" do
    it "gets zero" do
      @head.stub(:headers).and_return({})
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")

      res.get_size().should eq(0)
    end
  end

  context "head object fails" do
    it "still gets zero" do
      @storage.stub(:head_object).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")

      res.get_size().should eq(0)
    end
  end
end

describe "Remote resource remove" do
  before(:each) do
    @remove_file = double("remove_file")
    @remove_file.stub(:destroy).and_return(true)
    @remove_files = double("remove_files")
    @remove_files.stub(:head).and_return(@remove_file)
    @remove_files.stub(:length).and_return(1)
    @storage = mock_it(@remove_files)
  end

  context "remove succeeds" do
    it "returns true" do
      @remove_file.should_receive(:destroy).and_return(true)

      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.remove(false).should be_true
    end
  end

  context "remove container not found" do
    it "returns false and sets error" do
      @directories.stub(:get).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "remove file not found" do
    it "returns false and sets error" do
      @remove_files.stub(:head).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.cstatus.message.should eq("You don't have an object named ':container/files/river.txt'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "temp url" do
  before(:each) do
    @tmp_url_file = double("temp_url_file")
    @tmp_url_file.stub(:content_length).and_return(2)
    @tmp_url_file.stub(:content_type).and_return("text")
    @tmp_url_file.stub(:etag).and_return("2222222222")
    @tmp_url_file.stub(:last_modified).and_return("2/19/2013")
    @files = double("temp_url_files")
    @files.stub(:get).and_return(@tmp_url_file)
    @files.stub(:length).and_return(1)
    @storage = mock_it(@files)
  end

  context "tempurl succeeds" do
    it "return true" do
      @tmp_url_file.should_receive(:temp_signed_url).and_return("http://woot.com/")
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.tempurl(1212).should eq("http://woot.com/")
    end
  end

  context "tempurl container not found" do
    it "returns false and sets error" do
      @directories.stub(:get).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.tempurl(1212).should be_nil

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "temp url file not found" do
    it "returns false and sets error" do
      @files.stub(:get).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.tempurl(1212).should be_nil

      res.cstatus.message.should eq("Cannot find object ':container/files/river.txt'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "Remote resource grant" do
  before(:each) do
    @acl = double("acl")
    @acl.stub(:permissions).and_return("rw")
    @acl.stub(:users).and_return("bob@example.com")
    @storage = mock_it
  end

  context "grant for local resource" do
    it "returns false and sets error" do
      res = ResourceFactory.create_any(@storage, "/files/river.txt")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("ACLs of local objects are not supported: /files/river.txt")
      res.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "grant for container not found" do
    it "returns false and sets error" do
      @directories.stub(:get).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "grant failure" do
    it "returns false and sets error" do
      @directory.stub(:grant).and_raise(Exception.new("Grant failure"))
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("Exception granting permissions for ':container': Grant failure")
      res.cstatus.error_code.should eq(:general_error)
    end
  end

  context "save failure" do
    it "returns false and sets error" do
      @directory.stub(:save).and_raise(Exception.new("Save failure"))
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("Exception granting permissions for ':container': Save failure")
      res.cstatus.error_code.should eq(:general_error)
    end
  end

  context "grant good" do
    it "returns true and no error" do
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_true

      res.cstatus.is_success?.should be_true
    end
  end
end

describe "Remote resource revoke" do
  before(:each) do
    @acl = double("acl")
    @acl.stub(:permissions).and_return("rw")
    @acl.stub(:users).and_return("bob@example.com")
    @storage = mock_it
  end

  context "revoke for local resource" do
    it "returns false and sets error" do
      res = ResourceFactory.create_any(@storage, "/files/river.txt")

      res.revoke(@acl).should be_false

      res.cstatus.message.should eq("ACLs of local objects are not supported: /files/river.txt")
      res.cstatus.error_code.should eq(:incorrect_usage)
    end
  end

  context "revoke for container not found" do
    it "returns false and sets error" do
      @directories.stub(:get).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container")

      res.revoke(@acl).should be_false

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "revoke for file" do
    it "returns false and sets error" do
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.revoke(@acl).should be_false

      res.cstatus.message.should eq("ACLs are only supported on containers (e.g. :container).")
      res.cstatus.error_code.should eq(:not_supported)
    end
  end

  context "revoke failure" do
    it "returns false and sets error" do
      @directory.stub(:revoke).and_raise(Exception.new("Grant failure"))
      res = ResourceFactory.create_any(@storage, ":container")

      res.revoke(@acl).should be_false

      res.cstatus.message.should eq("Exception revoking permissions for ':container': Grant failure")
      res.cstatus.error_code.should eq(:general_error)
    end
  end

  context "save failure" do
    it "returns false and sets error" do
      @directory.stub(:save).and_raise(Exception.new("Save failure"))
      res = ResourceFactory.create_any(@storage, ":container")

      res.revoke(@acl).should be_false

      res.cstatus.message.should eq("Exception revoking permissions for ':container': Save failure")
      res.cstatus.error_code.should eq(:general_error)
    end
  end

  context "revoke good" do
    it "returns true and no error" do
      res = ResourceFactory.create_any(@storage, ":container")

      res.revoke(@acl).should be_true

      res.cstatus.is_success?.should be_true
    end
  end
end
