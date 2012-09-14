# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Storage-side path detection" do

  context "when given absolute path" do
    it 'should return that path' do
      path = HP::Cloud::Container.storage_destination_path('blah/archive.zip', '/tmp/archive.zip')
      path.should eql('blah/archive.zip')
    end
  end
  
  context "when given no path" do
    it 'should return original filename' do
      path = HP::Cloud::Container.storage_destination_path('', '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a nil" do
    it 'should return original filename' do
      path = HP::Cloud::Container.storage_destination_path(nil, '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a directory path" do
    it 'should return original filename appended to directory path' do
      path = HP::Cloud::Container.storage_destination_path('myfiles/', '/tmp/archive.zip')
      path.should eql('myfiles/archive.zip')
    end
  end
  
end

describe 'Parsing container names' do
  
  context "when given a normal string" do
    it 'should return the string' do
      HP::Cloud::Container.container_name_for_service('my_container').should eql('my_container')
    end
  end
  
  context "when given a resource string" do
    it 'should return container name as a simple string' do
      HP::Cloud::Container.container_name_for_service(':my_container').should eql('my_container')
    end
  end
  
  context "when given an object string" do
    it 'should throw an exception' do
      lambda {
        HP::Cloud::Container.container_name_for_service(':my_container/object.txt')
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Valid container names do not contain the '/' character: :my_container/object.txt")
      }
    end
  end
  
end

describe 'Parsing container resources' do
  
  context "when given a container-only resource" do
    before(:all) do
      @container, @path = HP::Cloud::Container.parse_resource(':my_container')
    end
    it 'should return container name' do
      @container.should eql('my_container')
    end
    it 'should return empty path' do
      @path.should be_nil
    end
  end
  
  context 'when given a container-only string' do
    before(:all) do
      @container, @path = HP::Cloud::Container.parse_resource('my_container')
    end
    it 'should return container name' do
      @container.should eql('my_container')
    end
    it 'should return empty path' do
      @path.should be_nil
    end
  end
  
  context 'when given a resource with an object path' do
    before(:all) do
      @container, @path = HP::Cloud::Container.parse_resource(':my_container/files/stuff/foo.txt')
    end
    it 'should return container name' do
      @container.should eql('my_container')
    end
    it 'should return object path' do
      @path.should eql('files/stuff/foo.txt')
    end
  end
  
  context 'when given a resource with a directory path' do 
    before(:all) do
      @container, @path = HP::Cloud::Container.parse_resource(':my_container/files/stuff/')
    end
    it 'should return container name' do
      @container.should eql('my_container')
    end
    it 'should return directory path' do
      @path.should eql('files/stuff/')
    end
  end
  
end

describe "Validating container names for virtual host" do
  
  before(:all) { @container = HP::Cloud::Container }
  
  it "should not allow empty strings" do
    @container.valid_virtualhost?('').should be_false
  end
  
  it "should not allow uppercase characters" do
    @container.valid_virtualhost?('UPPER').should be_false
  end
  
  it "should not allow funky characters" do
    @container.valid_virtualhost?('yøgürt').should be_false
  end
  
  it "should not allow strings that start with -" do
    @container.valid_virtualhost?('-mycontainer').should be_false
  end
  
  it "should not allow strings that end with -" do
    @container.valid_virtualhost?('mycontainer-').should be_false
  end
  
  it "should not allow strings longer than 63 characters" do
    @container.valid_virtualhost?('x' * 64).should be_false
  end
  
  it "should return true for valid names" do
    @container.valid_virtualhost?('my-bucket').should be_true
  end

end
