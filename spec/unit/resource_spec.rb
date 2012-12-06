require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Detecting mime type" do
  before(:each) do
    @storage = double("storage")
  end
  
  context "when this file" do
    it "should return application/x-ruby" do
      file = ResourceFactory.create_any(@storage, __FILE__)
      file.get_mime_type().should eq('application/x-ruby')
    end
  end

  context "when text file" do
    it "should return text/plain" do
      file = ResourceFactory.create_any(@storage, 'file.txt')
      file.get_mime_type().should eq('text/plain')
    end
  end

  context "when unknown file" do
    it "should return application/octet-stream" do
      file = ResourceFactory.create_any(@storage, 'file')
      file.get_mime_type().should eq('application/octet-stream')
    end
  end
end

describe "Resource construction" do
  before(:each) do
    @storage = double("storage")
  end
  
  context "when local file" do
    it "should return :file" do
      file = ResourceFactory.create_any(@storage, '/tmp/myfile.txt')

      file.fname.should eq('/tmp/myfile.txt')
      file.ftype.should eq(:file)
      file.container.should be_nil
      file.path.should eq('/tmp/myfile.txt')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_false
      file.isFile().should be_true
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when local file variant" do
    it "should return :file" do
      file = ResourceFactory.create_any(@storage, '~/documents/myfile.tar')

      file.fname.should eq('~/documents/myfile.tar')
      file.ftype.should eq(:file)
      file.container.should be_nil
      file.path.should eq('~/documents/myfile.tar')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_false
      file.isFile().should be_true
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      file = ResourceFactory.create_any(@storage, '/tmp/')

      file.fname.should eq('/tmp/')
      file.ftype.should eq(:directory)
      file.container.should be_nil
      file.path.should eq('/tmp')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      file = ResourceFactory.create_any(@storage, 'spec/tmp/nonexistant/')

      file.fname.should eq('spec/tmp/nonexistant/')
      file.ftype.should eq(:directory)
      file.container.should be_nil
      file.path.should eq('spec/tmp/nonexistant')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when local directory without slash" do
    it "should return :directory" do
      file = ResourceFactory.create_any(@storage, '/tmp')

      file.fname.should eq('/tmp')
      file.ftype.should eq(:directory)
      file.container.should be_nil
      file.path.should eq('/tmp')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when container" do
    it "should return :container" do
      file = ResourceFactory.create(@storage, ':my_container')

      file.fname.should eq(':my_container')
      file.ftype.should eq(:container)
      file.container.should eq('my_container')
      file.path.should eq('')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when full object path" do
    it "should return :object" do
      file = ResourceFactory.create(@storage, ':my_container/blah/archive.zip')

      file.fname.should eq(':my_container/blah/archive.zip')
      file.ftype.should eq(:object)
      file.container.should eq('my_container')
      file.path.should eq('blah/archive.zip')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_true
      file.is_valid?.should be_true
    end
  end
  
  context "when object directory path" do
    it "should return :container_directory" do
      file = ResourceFactory.create(@storage, ':my_container/blah/')

      file.fname.should eq(':my_container/blah/')
      file.ftype.should eq(:container_directory)
      file.container.should eq('my_container')
      file.path.should eq('blah')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when nothing" do
    it "should return :object_store" do
      file = ResourceFactory.create(@storage, '')

      file.fname.should eq('')
      file.ftype.should eq(:object_store)
      file.container.should be_nil
      file.path.should be_nil
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
      file.is_valid?.should be_true
    end
  end
  
  context "when url" do
    it "should return :shared_resource" do
      container = 'http://www.example.com/v1/123111111/tainer'
      path = 'subdir/a/objay.txt'
      file_name = container + '/' + path
      file = ResourceFactory.create(@storage, file_name)

      file.fname.should eq(file_name)
      file.ftype.should eq(:shared_resource)
      file.container.should eq(container)
      file.path.should eq(path)
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_true
      file.is_valid?.should be_true
      file.is_shared?.should be_true
    end
  end
  
  context "when url" do
    it "should return :shared_resource" do
      container = 'https://www.example.com/v1/123111111/tainer'
      path = 'objay.txt'
      file_name = container + '/' + path
      file = ResourceFactory.create(@storage, file_name)

      file.fname.should eq(file_name)
      file.ftype.should eq(:shared_resource)
      file.container.should eq(container)
      file.path.should eq(path)
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_true
      file.is_valid?.should be_true
      file.is_shared?.should be_true
    end
  end
end

describe 'Parsing container names' do
  
  context "when given a normal string" do
    it 'should return the string' do
      resource = ResourceFactory.create(@storage, 'mycontainer')
      resource.container.should eql('mycontainer')
      resource.ftype.should eq(:container)
    end
  end
  
  context "when given a resource string" do
    it 'should return container name as a simple string' do
      resource = ResourceFactory.create(@storage, ':mycontainer')
      resource.container.should eql('mycontainer')
      resource.ftype.should eq(:container)
    end
  end
  
  context "when given an object string with <" do
    it 'should throw an exception' do
      lambda {
        ResourceFactory.create(@storage, ':my_container/object<txt')
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Valid object names do not contain the '<' character: :my_container/object<txt")
      }
    end
  end
  
  context "when given an object string with >" do
    it 'should throw an exception' do
      lambda {
        ResourceFactory.create(@storage, ':my_container/object>txt')
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Valid object names do not contain the '>' character: :my_container/object>txt")
      }
    end
  end
  
  context "when given an object string with quote" do
    it 'should throw an exception' do
      lambda {
        ResourceFactory.create(@storage, ':my_container/object"txt')
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Valid object names do not contain the '\"' character: :my_container/object\"txt")
      }
    end
  end
  
  context "when given an object string" do
    it 'should throw an exception' do
      lambda {
        ContainerResource.new(@storage, ':my_container/object.txt')
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Valid container names do not contain the '/' character: :my_container/object.txt")
      }
    end
  end
  
  context "when given too long a string" do
    it 'should throw an exception' do
      lambda {
        too_long_container_name = 'A'*257
        ResourceFactory.create(@storage, too_long_container_name)
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Valid container names must be less than 256 characters long")
      }
    end
  end
  
  context "when given super long string" do
    it 'should throw an exception' do
      long_container_name = 'B'*256
      resource = ResourceFactory.create(@storage, long_container_name)
      resource.container.should eql(long_container_name)
      resource.ftype.should eq(:container)
    end
  end
  
end

describe "Validating container names for virtual host" do
  
  it "should not allow empty strings" do
    resource = ContainerResource.new(@storage, '')
    resource.valid_virtualhost?.should be_false
  end
  
  it "should not allow uppercase characters" do
    resource = ContainerResource.new(@storage, 'UPPER')
    resource.valid_virtualhost?.should be_false
  end
  
  it "should not allow funky characters" do
    resource = ContainerResource.new(@storage, 'yøgürt')
    resource.valid_virtualhost?.should be_false
  end
  
  it "should not allow strings that start with -" do
    resource = ContainerResource.new(@storage, '-mycontainer')
    resource.valid_virtualhost?.should be_false
  end
  
  it "should not allow strings that end with -" do
    resource = ContainerResource.new(@storage, 'mycontainer-')
    resource.valid_virtualhost?.should be_false
  end
  
  it "should not allow strings longer than 63 characters" do
    resource = ContainerResource.new(@storage, 'x' * 64)
    resource.valid_virtualhost?.should be_false
  end
  
  it "should return true for valid names" do
    resource = ContainerResource.new(@storage, 'my-bucket')
    resource.valid_virtualhost?.should be_true
  end

end
