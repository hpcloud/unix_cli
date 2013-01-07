require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include HP::Cloud

describe "SharedResource" do
  before(:each) do
    @file_name0 = "http://example.com/v1/12312312/tainer/subdir/"
    @file_name1 = "http://example.com/v1/12312312/tainer/subdir/whatever.txt"
    @file_name2 = "http://example.com/v1/12312312/tainer/foo.txt"
    @file_name3 = "http://example.com/v1/12312312/tainer/"
    @file0 = double("file0")
    @file0.stub(:key).and_return("subdir/")
    @file0.stub(:content_length).and_return(1)
    @file1 = double("file1")
    @file1.stub(:key).and_return("subdir/whatever.txt")
    @file1.stub(:content_length).and_return(111)
    @file2 = double("file2")
    @file2.stub(:key).and_return("foo.txt")
    @file2.stub(:content_length).and_return(222)
    @file3 = double("file2")
    @file3.stub(:key).and_return("")
    @file3.stub(:content_length).and_return(2)
    @files = double("files")
    @files.stub(:get).with("subdir/").and_return(@file0)
    @files.stub(:get).with("subdir/whatever.txt").and_return(@file1)
    @files.stub(:get).with("foo.txt").and_return(@file2)
    @files.stub(:each).and_yield(@file1).and_yield(@file2)
    @directory = double("directory")
    @directory.stub(:files).and_return(@files)
    @directories = double("directories")
    @directories.stub(:get).and_return(@directory)
    @storage = double("storage")
    @storage.stub(:shared_directories).and_return(@directories)
  end

  context "various methods that read the header" do
    it "they are cool" do
      to = ResourceFactory.create(@storage, @file_name1)

      to.valid_source().should be_true
      to.valid_container().should be_true
      to.get_container().should be_true
      to.get_size().should eq(111)

      to.cstatus.is_success?.should be_true
    end
  end

  context "valid destination" do
    it "is real file true" do
      source = double("source")
      source.stub(:isMulti).and_return(true)
      to = ResourceFactory.create(@storage, @file_name0)
      to.path.should eq("subdir/")
      to.ftype.should eq(:shared_directory)

      to.valid_destination(source).should be_true

      to.cstatus.is_success?.should be_true
    end
  end

  context "when just a container" do
    it "gets all the files" do
      res = ResourceFactory.create(@storage, @file_name3)
      ray = Array.new

      res.foreach{ |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq("http://example.com/v1/12312312/tainer/foo.txt")
      ray[1].should eq("http://example.com/v1/12312312/tainer/subdir/whatever.txt")
      ray.length.should eq(2)
    end
  end

  context "when just a subdir" do
    it "gets all the files" do
      res = ResourceFactory.create(@storage, @file_name0)
      ray = Array.new

      res.foreach{ |x| ray.push(x.fname) }

      ray.sort!
      ray[0].should eq("http://example.com/v1/12312312/tainer/subdir/whatever.txt")
      ray.length.should eq(1)
    end
  end

  context "set_destination" do
    it "gets all the files" do
      res0 = ResourceFactory.create(@storage, @file_name0)
      res1 = ResourceFactory.create(@storage, @file_name1)
      res2 = ResourceFactory.create(@storage, @file_name2)
      res3 = ResourceFactory.create(@storage, @file_name3)

      res0.set_destination("noo.txt")
      res1.set_destination("noo.txt")
      res2.set_destination("noo.txt")
      res3.set_destination("noo.txt")

      res0.destination.should eq("subdir/noo.txt")
      res1.destination.should eq("subdir/whatever.txt")
      res2.destination.should eq("foo.txt")
      res3.destination.should eq("noo.txt")
    end
  end

end
