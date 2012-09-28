require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "Detecting mime type" do
  before(:each) do
    @storage = double("storage")
  end
  
  context "when this file" do
    it "should return application/x-ruby" do
      file = Resource.create(@storage, __FILE__)
      file.get_mime_type().should eq('application/x-ruby')
    end
  end

  context "when text file" do
    it "should return text/plain" do
      file = Resource.create(@storage, 'file.txt')
      file.get_mime_type().should eq('text/plain')
    end
  end

  context "when unknown file" do
    it "should return application/octet-stream" do
      file = Resource.create(@storage, 'file')
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
      file = Resource.create(@storage, '/tmp/myfile.txt')

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
      file = Resource.create(@storage, '~/documents/myfile.tar')

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
      file = Resource.create(@storage, '/tmp/')

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
      file = Resource.create(@storage, 'spec/tmp/nonexistant/')

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
      file = Resource.create(@storage, '/tmp')

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
      file = Resource.create(@storage, ':my_container')

      file.fname.should eql(':my_container')
      file.ftype.should eql(:container)
      file.container.should eql('my_container')
      file.path.should eql('')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when full object path" do
    it "should return :object" do
      file = Resource.create(@storage, ':my_container/blah/archive.zip')

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
      file = Resource.create(@storage, ':my_container/blah/')

      file.fname.should eql(':my_container/blah/')
      file.ftype.should eql(:container_directory)
      file.container.should eql('my_container')
      file.path.should eq('blah')
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
  
  context "when nothing" do
    it "should return :object_store" do
      file = Resource.create(@storage, '')

      file.fname.should eql('')
      file.ftype.should eql(:object_store)
      file.container.should be_nil
      file.path.should be_nil
      file.isLocal().should be_false
      file.isRemote().should be_true
      file.isDirectory().should be_true
      file.isFile().should be_false
      file.isObject().should be_false
    end
  end
end
