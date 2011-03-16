require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Resource detection" do
  
  context "when local file" do
    it "should return :file" do
      HPCloud::Resource.detect_type('/tmp/myfile.txt').should eql(:file)
    end
  end
  
  context "when local file variant" do
    it "should return :file" do
      HPCloud::Resource.detect_type('~/documents/myfile.tar').should eql(:file)
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      HPCloud::Resource.detect_type('/tmp/').should eql(:directory)
    end
  end
  
  context "when bucket" do
    it "should return :bucket" do
      HPCloud::Resource.detect_type(':my_bucket').should eql(:bucket)
    end
  end
  
  context "when full object path" do
    it "should return :object" do
      HPCloud::Resource.detect_type(':my_bucket/blah/archive.zip').should eql(:object)
    end
  end
  
  context "when object directory path" do
    it "should return :bucket_directory" do
      HPCloud::Resource.detect_type(':my_bucket/blah/').should eql(:bucket_directory)
    end
  end
  
end

describe "Detecting mime type" do
  
  pending 'tests' do
  end
  
end