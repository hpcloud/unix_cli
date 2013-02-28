require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

class LargeHelper
  @@chunk_size = 200

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
    config.set(:storage_segment_size, LargeHelper.chunk_size)
    config.set(:storage_max_size, LargeHelper.chunk_size)
    config.write
  end

  before(:each) do
    cptr('remove -f :largetest')
    cptr('containers:add :largetest')
  end

  context "Large file copy one under" do
    it "should copy file" do
      filename = 'oneunder'
      siz = (LargeHelper.chunk_size - 1)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :largetest')
      rsp.stderr.should eq("")
      rsp.stdout.should eq(filename + "\n")
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy exactly" do
    it "should copy file" do
      filename = 'exactly'
      siz = LargeHelper.chunk_size
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy one over" do
    it "should copy file" do
      filename = 'oneover'
      siz = (LargeHelper.chunk_size + 1)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  context "Large file copy many over" do
    it "should copy file" do
      filename = 'manyover'
      siz = (LargeHelper.chunk_size*10 + 11)
      fname, body = LargeHelper.build_file(filename, siz)

      rsp = cptr("copy #{fname} :largetest")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{fname} => :largetest\n")
      rsp.exit_status.should be_exit(:success)
      LargeHelper.verify_body(filename, body).should be_true
    end
  end
    
  after(:all) do
    #ConfigHelper.reset()
  end
end
