# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  
  context "when given too long a string" do
    it 'should throw an exception' do
      lambda {
        HP::Cloud::Container.container_name_for_service('A'*257)
      }.should raise_error(Exception) {|e|
        e.to_s.should include("Valid container names must be less than 256 characters long")
      }
    end
  end
  
  context "when given super long string" do
    it 'should throw an exception' do
      long_container_name = 'B'*256
      HP::Cloud::Container.container_name_for_service(long_container_name).should eql(long_container_name)
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
