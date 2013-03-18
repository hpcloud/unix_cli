require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class LargeHelper
  @@segment_size = 1024
  @@chunk_size = 512

  def self.segment_size
    return @@segment_size
  end

  def self.chunk_size
    return @@chunk_size
  end

  def self.build_body(siz)
    cnt = 0
    ray = []
    chars = ('a'..'z').to_a
    while cnt < siz do
      idx = rand(25).to_i
      ray << chars[idx]
      cnt += 1
    end
    return ray.join('')
  end

  def self.build_file(filename, siz)
    fname = 'spec/tmp/' + filename
    file = File.new(fname, 'w+')
    body = LargeHelper.build_body(siz)
    file.write(body)
    file.close
    return fname, body
  end

  def self.verify_body(filename, body)
    download = 'spec/tmp/download'
    FileUtils.rm_f(download)
    rsp = cptr("copy :largetest/#{filename} spec/tmp/download")
    file = File.new(download)
    result = file.read
    return result == body
  end
end

describe "Copy large" do

  before(:all) do
    ConfigHelper.use_tmp()
    config = HP::Cloud::Config.new
    config.set(:storage_segment_size, LargeHelper.segment_size)
    config.set(:storage_max_size, LargeHelper.segment_size)
    config.set(:storage_chunk_size, LargeHelper.chunk_size)
    config.write
  end

  before(:each) do
    cptr('remove -f :largetest')
    cptr('containers:add :largetest')
  end

  context "Large file copy one under" do
    it "should copy file" do
      filename = 'oneunder'
      siz = (LargeHelper.segment_size - 1)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :largetest -c sname,size')
      rsp.stderr.should eq("")
      siz = (LargeHelper.segment_size) - 1
      rsp.stdout.should eq("oneunder #{siz}\n")
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy exactly" do
    it "should copy file" do
      filename = 'exactly'
      siz = LargeHelper.segment_size
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :largetest -c sname,size')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("exactly #{LargeHelper.segment_size}\n")
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy one over" do
    it "should copy file" do
      filename = 'oneover'
      siz = (LargeHelper.segment_size + 1)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :largetest -c sname,size')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("oneover 0\noneover.segment.0000000001 #{LargeHelper.segment_size}\noneover.segment.0000000002 1\n")
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy many over" do
    it "should copy file" do
      filename = 'manyover'
      siz = (LargeHelper.segment_size*10 + 11)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :largetest -c sname,size')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("manyover 0\nmanyover.segment.0000000001 #{LargeHelper.segment_size}\nmanyover.segment.0000000002 #{LargeHelper.segment_size}\nmanyover.segment.0000000003 #{LargeHelper.segment_size}\nmanyover.segment.0000000004 #{LargeHelper.segment_size}\nmanyover.segment.0000000005 #{LargeHelper.segment_size}\nmanyover.segment.0000000006 #{LargeHelper.segment_size}\nmanyover.segment.0000000007 #{LargeHelper.segment_size}\nmanyover.segment.0000000008 #{LargeHelper.segment_size}\nmanyover.segment.0000000009 #{LargeHelper.segment_size}\nmanyover.segment.0000000010 #{LargeHelper.segment_size}\nmanyover.segment.0000000011 11\n")
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  after(:all) do
    ConfigHelper.reset()
  end
end
