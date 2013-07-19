require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

def mock_it
    @put_container = double("put_container")
    @container_headers = {
        'Content-Length' => 0,
        'X-Container-Object-Count' => 3,
        'X-Container-Bytes-Used' => 2342,
        'X-Container-Reader' => '*:sue@example.com',
        'X-Container-Writer' => '*:bob@example.com,*:pam@example.com'
      }
    @container_head = double("head")
    @container_head.stub(:headers).and_return(@container_headers)
    @container_get = double("get_container")
    @container_get.stub(:headers).and_return(@container_headers)
    @files = [
        {'name'=>"files/cantread.txt",'bytes'=>3},
        {'name'=>"files/foo.txt",'bytes'=>5},
        {'name'=>"files/subdir/with space.txt",'bytes'=>4}
      ]
    @container_get.stub(:body).and_return(@files)
    @object_head = double("head")
    @object_head.stub(:headers).and_return({ "Content-Length" => 9 })
    @storage = double("storage")
    @storage.stub(:head_container).and_return(@container_head)
    @storage.stub(:get_container).and_return(@container_get)
    @storage.stub(:head_object).and_return(@object_head)
    @storage.stub(:get_object).and_yield("chunk", 0, 0)
    @storage.stub(:put_object).and_return(double("put_object"))
    @storage.stub(:put_container).and_return(double("put_container"))
    @storage.stub(:url).and_return("http://localhost")
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
      @storage.stub(:head_container).and_return(nil)
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
      @storage.stub(:head_container).and_return(nil)
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
      @storage.stub(:head_container).and_return(nil)
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
      @storage = mock_it

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
    @storage = mock_it
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
      @storage.stub(:head_container).and_return(nil)
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
      src = ResourceFactory.create_any(@storage, ":container/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, "spec/tmp/result.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote file source and destination" do
    it "copies the data" do
      src = ResourceFactory.create_any(@storage, ":container/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, ":container/copy.txt")

      dest.copy(src).should be_true
    end
  end

  context "when remote files, but source does not exist" do
    it "fails" do
      @storage.stub(:put_object).and_raise(Fog::Storage::HP::NotFound)
      src = ResourceFactory.create_any(@storage, ":container/files/foo.txt")
      dest = ResourceFactory.create_any(@storage, ":container/copy.txt")

      dest.copy(src).should be_false

      dest.cstatus.message.should eq("The specified object does not exist.")
      dest.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "Read directory" do
  before(:each) do
    @storage = mock_it
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
    @storage = mock_it
  end

  context "get valid size" do
    it "new size" do
      res = ResourceFactory.create_any(@storage, ":container/files/subdir/")

      res.get_size().should eq(9)
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
    @storage = mock_it
  end

  context "remove container not found" do
    it "returns false and sets error" do
      @storage.stub(:head_container).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "remove file not found" do
    it "returns false and sets error" do
      @storage.stub(:delete_object).and_raise(Fog::Storage::HP::NotFound.new)
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.remove(false).should be_false

      res.cstatus.message.should eq("You don't have an object named ':container/files/river.txt'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end
end

describe "temp url" do
  before(:each) do
    @storage = mock_it
  end

  context "tempurl succeeds" do
    it "return true" do
      @storage.should_receive(:get_object_temp_url).and_return("http://woot.com/")
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.tempurl(1212).should eq("http://woot.com/")
    end
  end

  context "tempurl put" do
    it "return true" do
      @storage.should_receive(:get_object_temp_url).and_return("http://woot.com/")
      res = ResourceFactory.create_any(@storage, ":container/files/river.txt")

      res.tempurl(3333, true).should eq("http://woot.com/")
    end
  end

  context "temp url file not found" do
    it "returns false and sets error" do
      @storage.stub(:head_object).and_return(nil)
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
    @acl.stub(:readers).and_return(["sue@example.com"])
    @acl.stub(:writers).and_return(["bob@example.com"])
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
      @storage.stub(:head_container).and_return(nil)
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("Cannot find container ':container'.")
      res.cstatus.error_code.should eq(:not_found)
    end
  end

  context "grant failure" do
    it "returns false and sets error" do
      @storage.stub(:put_container).and_raise(Exception.new("Grant failure"))
      res = ResourceFactory.create_any(@storage, ":container")

      res.grant(@acl).should be_false

      res.cstatus.message.should eq("Exception granting permissions for ':container': Grant failure")
      res.cstatus.error_code.should eq(:general_error)
    end
  end

  context "save failure" do
    it "returns false and sets error" do
      @storage.stub(:put_container).and_raise(Exception.new("Save failure"))
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
    @acl.stub(:readers).and_return(["sue@example.com"])
    @acl.stub(:writers).and_return(["bob@example.com"])
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
      @storage.stub(:head_container).and_return(nil)
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

  context "save failure" do
    it "returns false and sets error" do
      @storage.stub(:put_container).and_raise(Exception.new("Save failure"))
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

  context "object valid_meta_key" do
    it "returns right thing" do
      res = ResourceFactory.create_any(@storage, ":container/foo.txt")

      res.valid_metadata_key?('X-Object-Meta-Foo').should be_true
      res.valid_metadata_key?('Content-Type').should be_true
      res.valid_metadata_key?('Content-Disposition').should be_true
      res.valid_metadata_key?('X-Delete-At').should be_true
      res.valid_metadata_key?('X-Delete-After').should be_true
      res.valid_metadata_key?('X-Object-Manifest').should be_true
      res.valid_metadata_key?('Bogus').should be_false
    end
  end

  context "container valid_meta_key" do
    it "returns right thing" do
      res = ResourceFactory.create_any(@storage, ":container")

      res.valid_metadata_key?('X-Container-Meta-Foo').should be_true
      res.valid_metadata_key?('Content-Type').should be_false
      res.valid_metadata_key?('Authorization').should be_true
      res.valid_metadata_key?('X-Auth-Token').should be_true
      res.valid_metadata_key?('X-Container-Read').should be_true
      res.valid_metadata_key?('X-Container-Write').should be_true
      res.valid_metadata_key?('X-Container-Sync-To').should be_true
      res.valid_metadata_key?('X-Container-Sync-Key').should be_true
      res.valid_metadata_key?('X-Container-Meta-Web-Index').should be_true
      res.valid_metadata_key?('X-Container-Meta-Web-Error').should be_true
      res.valid_metadata_key?('X-Container-Meta-Web-Listings').should be_true
      res.valid_metadata_key?('X-Container-Meta-Web-Listings-CSS').should be_true
      res.valid_metadata_key?('X-Versions-Location').should be_true
      res.valid_metadata_key?('Bogus').should be_false
    end
  end
end
