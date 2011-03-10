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
