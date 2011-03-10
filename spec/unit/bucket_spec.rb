require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Storage-side path detection" do

  context "when given absolute path" do
    it 'should return that path' do
      path = HPCloud::Bucket.storage_destination_path('blah/archive.zip', '/tmp/archive.zip')
      path.should eql('blah/archive.zip')
    end
  end
  
  context "when given no path" do
    it 'should return original filename' do
      path = HPCloud::Bucket.storage_destination_path('', '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a nil" do
    it 'should return original filename' do
      path = HPCloud::Bucket.storage_destination_path(nil, '/tmp/archive.zip')
      path.should eql('archive.zip')
    end
  end
  
  context "when given a directory path" do
    it 'should return original filename appended to directory path' do
      path = HPCloud::Bucket.storage_destination_path('myfiles/', '/tmp/archive.zip')
      path.should eql('myfiles/archive.zip')
    end
  end
  
end

describe 'Parsing bucket names' do
  
  context "when given a normal string" do
    it 'should return the string' do
      HPCloud::Bucket.parse_bucket_name('my_bucket').should eql('my_bucket')
    end
  end
  
  context "when given a resource string" do
    it 'should return bucket name as a simple string' do
      HPCloud::Bucket.parse_bucket_name(':my_bucket').should eql('my_bucket')
    end
  end
  
end