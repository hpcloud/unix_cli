require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command recrusive" do
  
  before(:all) do
    @hp_svc = storage_connection
    purge_container('recurse_local')
    purge_container('recurse_local_nested')
    purge_container('recurse_empty')
    purge_container('recurse_remote')
    purge_container('clone_container')
    purge_container('clone_partial')
    @hp_svc.put_container('recurse_local')
    @hp_svc.put_container('recurse_local_nested')
    @hp_svc.put_container('recurse_empty')
    @hp_svc.put_container('recurse_remote')
    @hp_svc.put_container('clone_container')
    @hp_svc.put_container('clone_partial')
    FileUtils.rm_rf('spec/tmp/empty')
    FileUtils.rm_rf('spec/tmp/recurse')
    FileUtils.mkpath('spec/tmp/empty')
    FileUtils.mkpath('spec/tmp/recurse/single')
    FileUtils.mkpath('spec/tmp/recurse/nested')
    rsp = cptr("copy spec/fixtures/files/Matryoshka :recurse_remote")
    rsp.exit_status.should be_exit(:success)
  end
  
  context "copying local directory to remote container" do
    it "should report success and copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev :recurse_local")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev => :recurse_local\n")
      rsp.exit_status.should be_exit(:success)
      @container = @hp_svc.get_container('recurse_local')
      @container.body[0]['name'].should eq("Gorbachev/Andropov.txt")
      @container.body[1]['name'].should eq("Gorbachev/Chernenko.txt")
      @container.body[2]['name'].should eq("Gorbachev/Mikhail.txt")
      @container.body.length.should eq(3)
    end
  end

  context "copying multilevel local directory to remote container" do
    it "should report success and copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/ :recurse_local_nested/nested/")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/ => :recurse_local_nested/nested/\n")
      rsp.exit_status.should be_exit(:success)
      @container = @hp_svc.get_container('recurse_local_nested')
      ray = []
      ray << @container.body[0]['name']
      ray << @container.body[1]['name']
      ray << @container.body[2]['name']
      ray << @container.body[3]['name']
      ray << @container.body[4]['name']
      ray << @container.body[5]['name']
      ray.sort!
      ray[0].should eq("nested/Matryoshka/Putin/Medvedev.txt")
      ray[1].should eq("nested/Matryoshka/Putin/Vladimir.txt")
      ray[2].should eq("nested/Matryoshka/Putin/Yeltsin/Boris.txt")
      ray[3].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt")
      ray[4].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      ray[5].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      @container.body.length.should eq(6)
    end
  end

  context "copying empty local directory to remote container" do
    it "should report not_found and not copy" do
      rsp = cptr("copy spec/tmp/empty :recurse_empty")

      rsp.stderr.should eq("No files found matching source 'spec/tmp/empty'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
      @container = @hp_svc.get_container('recurse_empty')
      @container.body.length.should eq(0)
    end
  end

  context "copying directory not found to remote container" do
    it "should report not_found and not copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Brezhnev/ :recurse_empty")

      rsp.stderr.should eq("File not found at 'spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Brezhnev/'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
      @container = @hp_svc.get_container('recurse_empty')
      @container.body.length.should eq(0)
    end
  end

  context "copying remote directory to local" do
    it "should report success" do
      rsp = cptr("copy :recurse_remote/Matryoshka/Putin/Yeltsin/Gorbachev/ spec/tmp/recurse/single/")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :recurse_remote/Matryoshka/Putin/Yeltsin/Gorbachev/ => spec/tmp/recurse/single/\n")
      rsp.exit_status.should be_exit(:success)
      entries = Dir.entries('spec/tmp/recurse/single').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Gorbachev")
      entries.length.should eq(3)

      entries = Dir.entries('spec/tmp/recurse/single/Gorbachev').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Andropov.txt")
      entries[3].should eq("Chernenko.txt")
      entries[4].should eq("Mikhail.txt")
      entries.length.should eq(5)
    end
  end

  context "copying multilevel local directory to container" do
    it "should report success" do
      rsp = cptr("copy :recurse_remote/Matryoshka/ spec/tmp/recurse/nested/")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :recurse_remote/Matryoshka/ => spec/tmp/recurse/nested/\n")
      rsp.exit_status.should be_exit(:success)
      entries = Dir.entries('spec/tmp/recurse/nested/Matryoshka').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Putin")
      entries.length.should eq(3)

      entries = Dir.entries('spec/tmp/recurse/nested/Matryoshka/Putin').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Medvedev.txt")
      entries[3].should eq("Vladimir.txt")
      entries[4].should eq("Yeltsin")
      entries.length.should eq(5)

      entries = Dir.entries('spec/tmp/recurse/nested/Matryoshka/Putin/Yeltsin').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Boris.txt")
      entries[3].should eq("Gorbachev")
      entries.length.should eq(4)

      entries = Dir.entries('spec/tmp/recurse/nested/Matryoshka/Putin/Yeltsin/Gorbachev').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Andropov.txt")
      entries[3].should eq("Chernenko.txt")
      entries[4].should eq("Mikhail.txt")
      entries.length.should eq(5)
    end
  end

  context "clone remote selected items in container" do
    it "should report success" do
      rsp = cptr("copy :recurse_remote/Matryoshka/Putin/Yeltsin/Gorbachev/ :clone_partial")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :recurse_remote/Matryoshka/Putin/Yeltsin/Gorbachev/ => :clone_partial\n")
      rsp.exit_status.should be_exit(:success)
      @container = @hp_svc.get_container('clone_partial')
      @container.body[0]['name'].should eq("Gorbachev/Andropov.txt")
      @container.body[1]['name'].should eq("Gorbachev/Chernenko.txt")
      @container.body[2]['name'].should eq("Gorbachev/Mikhail.txt")
      @container.body.length.should eq(3)
    end
  end

  context "clone remote container to another container" do
    it "should report success" do
      rsp = cptr("copy :recurse_remote :clone_container/nested/")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :recurse_remote => :clone_container/nested/\n")
      rsp.exit_status.should be_exit(:success)
      @container = @hp_svc.get_container('clone_container')
      @container.body[0]['name'].should eq("nested/Matryoshka/Putin/Medvedev.txt")
      @container.body[1]['name'].should eq("nested/Matryoshka/Putin/Vladimir.txt")
      @container.body[2]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Boris.txt")
      @container.body[3]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt")
      @container.body[4]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      @container.body[5]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      @container.body.length.should eq(6)
    end
  end

  after(:all) do
    FileUtils.rm_rf('spec/tmp/empty')
    FileUtils.rm_rf('spec/tmp/recurse')
    purge_container('recurse_local')
    purge_container('recurse_local_nested')
    purge_container('recurse_empty')
    purge_container('recurse_remote')
    purge_container('container_clone')
    purge_container('partial_clone')
  end
end
