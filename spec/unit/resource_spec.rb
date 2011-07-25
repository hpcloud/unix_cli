require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Resource detection" do
  
  context "when local file" do
    it "should return :file" do
      HP::Scalene::Resource.detect_type('/tmp/myfile.txt').should eql(:file)
    end
  end
  
  context "when local file variant" do
    it "should return :file" do
      HP::Scalene::Resource.detect_type('~/documents/myfile.tar').should eql(:file)
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      HP::Scalene::Resource.detect_type('/tmp/').should eql(:directory)
    end
  end
  
  context "when container" do
    it "should return :container" do
      HP::Scalene::Resource.detect_type(':my_container').should eql(:container)
    end
  end
  
  context "when full object path" do
    it "should return :object" do
      HP::Scalene::Resource.detect_type(':my_container/blah/archive.zip').should eql(:object)
    end
  end
  
  context "when object directory path" do
    it "should return :container_directory" do
      HP::Scalene::Resource.detect_type(':my_container/blah/').should eql(:container_directory)
    end
  end
  
end

describe "Detecting mime type" do
  
  pending 'tests' do
  end
  
end