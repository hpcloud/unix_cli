require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Storage-side path detection" do

  context "when given absolute path" do
    it 'should return that path' do
      path = HP::Scalene::Bucket.storage_destination_path('blah/archive.zip', '/tmp/archive.zip')
      path.should eql('blah/archive.zip')
    end
  end
  
  context "when given no path" do
    it 'should return original filename' do
      path = HP::Scalene::Bucket.storage_destination_path('', '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a nil" do
    it 'should return original filename' do
      path = HP::Scalene::Bucket.storage_destination_path(nil, '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a directory path" do
    it 'should return original filename appended to directory path' do
      path = HP::Scalene::Bucket.storage_destination_path('myfiles/', '/tmp/archive.zip')
      path.should eql('myfiles/archive.zip')
    end
  end
  
end

describe 'Parsing bucket names' do
  
  context "when given a normal string" do
    it 'should return the string' do
      HP::Scalene::Bucket.bucket_name_for_service('my_bucket').should eql('my_bucket')
    end
  end
  
  context "when given a resource string" do
    it 'should return bucket name as a simple string' do
      HP::Scalene::Bucket.bucket_name_for_service(':my_bucket').should eql('my_bucket')
    end
  end
  
end

describe 'Parsing bucket resources' do
  
  context "when given a bucket-only resource" do
    before(:all) do
      @bucket, @path = HP::Scalene::Bucket.parse_resource(':my_bucket')
    end
    it 'should return bucket name' do
      @bucket.should eql('my_bucket')
    end
    it 'should return empty path' do
      @path.should be_nil
    end
  end
  
  context 'when given a bucket-only string' do
    before(:all) do
      @bucket, @path = HP::Scalene::Bucket.parse_resource('my_bucket')
    end
    it 'should return bucket name' do
      @bucket.should eql('my_bucket')
    end
    it 'should return empty path' do
      @path.should be_nil
    end
  end
  
  context 'when given a resource with an object path' do
    before(:all) do
      @bucket, @path = HP::Scalene::Bucket.parse_resource(':my_bucket/files/stuff/foo.txt')
    end
    it 'should return bucket name' do
      @bucket.should eql('my_bucket')
    end
    it 'should return object path' do
      @path.should eql('files/stuff/foo.txt')
    end
  end
  
  context 'when given a resource with a directory path' do 
    before(:all) do
      @bucket, @path = HP::Scalene::Bucket.parse_resource(':my_bucket/files/stuff/')
    end
    it 'should return bucket name' do
      @bucket.should eql('my_bucket')
    end
    it 'should return directory path' do
      @path.should eql('files/stuff/')
    end
  end
  
end