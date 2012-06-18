require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Detecting mime type" do
  
  context "when this file" do
    it "should return text/plain" do
      file = HP::Cloud::Resource.new(__FILE__)
      file.get_mime_type().should eq('text/plain')
    end
  end
  
end

describe "Resource construction" do
  
  context "when local file" do
    it "should return :file" do
      file = HP::Cloud::Resource.new('/tmp/myfile.txt')

      file.fname.should eql('/tmp/myfile.txt')
      file.ftype.should eql(:file)
      file.container.should be_nil
      file.path.should eq('/tmp/myfile.txt')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_false
      file.isFile().should be_true
      file.isObject().should be_false
    end
  end
  
  context "when local file variant" do
    it "should return :file" do
      file = HP::Cloud::Resource.new('~/documents/myfile.tar')

      file.fname.should eql('~/documents/myfile.tar')
      file.ftype.should eql(:file)
      file.container.should be_nil
      file.path.should eq('~/documents/myfile.tar')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_false
      file.isFile().should be_true
      file.isObject().should be_false
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      file = HP::Cloud::Resource.new('/tmp/')

      file.fname.should eql('/tmp/')
      file.ftype.should eql(:directory)
      file.container.should be_nil
      file.path.should eq('/tmp')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when local directory" do
    it "should return :directory" do
      file = HP::Cloud::Resource.new('spec/tmp/nonexistant/')

      file.fname.should eql('spec/tmp/nonexistant/')
      file.ftype.should eql(:directory)
      file.container.should be_nil
      file.path.should eq('spec/tmp/nonexistant')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when local directory without slash" do
    it "should return :directory" do
      file = HP::Cloud::Resource.new('/tmp')

      file.fname.should eql('/tmp')
      file.ftype.should eql(:directory)
      file.container.should be_nil
      file.path.should eq('/tmp')
      file.isLocal().should be_true
      file.isRemote().should be_false
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when container" do
    it "should return :container" do
      file = HP::Cloud::Resource.new(':my_container')

      file.fname.should eql(':my_container')
      file.ftype.should eql(:container)
      file.container.should eql('my_container')
      file.path.should eql('')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when full object path" do
    it "should return :object" do
      file = HP::Cloud::Resource.new(':my_container/blah/archive.zip')

      file.fname.should eql(':my_container/blah/archive.zip')
      file.ftype.should eql(:object)
      file.container.should eql('my_container')
      file.path.should eq('blah/archive.zip')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_true
    end
  end
  
  context "when object directory path" do
    it "should return :container_directory" do
      file = HP::Cloud::Resource.new(':my_container/blah/')

      file.fname.should eql(':my_container/blah/')
      file.ftype.should eql(:container_directory)
      file.container.should eql('my_container')
      file.path.should eq('blah')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_false
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
end
