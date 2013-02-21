require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy large" do
  @@chunk_size = 200

  before(:all) do
    ConfigHelper.use_tmp()
    config = Config.new
    config.set(:storage_chunk_size, @@chunk_size)
    config.write
  end

  context "Large file copy one under" do
    it "should copy file" do
      rsp = cptr('copy :cross :duplicate')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :cross => :duplicate\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :duplicate')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Yeltsin/Boris.txt\nYeltsin/Gorbachev/Andropov.txt\nYeltsin/Gorbachev/Chernenko.txt\nYeltsin/Gorbachev/Mikhail.txt\n")
    end
  end
    
  context "when migrate" do
    it "should copy files" do
      rsp = cptr('migrate secondary :cross :migrate')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Migrated :cross => :migrate\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr('list :migrate')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Yeltsin/Boris.txt\nYeltsin/Gorbachev/Andropov.txt\nYeltsin/Gorbachev/Chernenko.txt\nYeltsin/Gorbachev/Mikhail.txt\n")
    end
  end

  after(:all) do
    ConfigHelper.reset()
  end
end
