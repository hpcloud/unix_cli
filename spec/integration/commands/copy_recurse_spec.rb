require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command recrusive" do
  
  before(:all) do
    @hp_svc = storage_connection
  end
  
  context "copying local directory to remote container" do
    
    before(:all) do
      purge_container('recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev', ':recurse']) }
      @container = @hp_svc.get_container('recurse')
    end
    
    it "should report success" do
      @response.should eql("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev => :recurse\n")
      @exit_status.should be_exit(:success)
    end
    
    it "container should have three files" do
      @container.body[0]['name'].should eq("Gorbachev/Andropov.txt")
      @container.body[1]['name'].should eq("Gorbachev/Chernenko.txt")
      @container.body[2]['name'].should eq("Gorbachev/Mikhail.txt")
      @container.body.length.should eq(3)
    end
    
  end

  context "copying multilevel local directory to remote container" do
    
    before(:all) do
      purge_container('recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/', ':recurse/nested/']) }
      @exit_status.should be_exit(:success)
      @container = @hp_svc.get_container('recurse')
    end
    
    it "should report success" do
      @response.should eql("Copied spec/fixtures/files/Matryoshka/ => :recurse/nested/\n")
      @exit_status.should be_exit(:success)
    end
    
    it "container should have six files" do
      @container.body[0]['name'].should eq("nested/Matryoshka/Putin/Medvedev.txt")
      @container.body[1]['name'].should eq("nested/Matryoshka/Putin/Vladimir.txt")
      @container.body[2]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Boris.txt")
      @container.body[3]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt")
      @container.body[4]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      @container.body[5]['name'].should eq("nested/Matryoshka/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      @container.body.length.should eq(6)
    end
    
  end

  context "copying remote directory to local" do
    
    before(:all) do
      purge_container('recurse')
      FileUtils.rm_rf('spec/tmp/recurse')
      Dir.mkdir('spec/tmp/recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev', ':recurse']) }
      @response.should eql("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev => :recurse\n")
      @exit_status.should be_exit(:success)
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':recurse', 'spec/tmp/recurse/']) }
    end
    
    it "should report success" do
      @response.should eql("Copied :recurse => spec/tmp/recurse/\n")
      @exit_status.should be_exit(:success)
    end
    
    it "container should have three files" do
      entries = Dir.entries('spec/tmp/recurse').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Gorbachev")
      entries.length.should eq(3)

      entries = Dir.entries('spec/tmp/recurse/Gorbachev').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Andropov.txt")
      entries[3].should eq("Chernenko.txt")
      entries[4].should eq("Mikhail.txt")
      entries.length.should eq(5)
    end
    
  end

  context "copying multilevel local directory to container" do
    
    before(:all) do
      purge_container('recurse')
      FileUtils.rm_rf('spec/tmp/recurse')
      Dir.mkdir('spec/tmp/recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/', ':recurse/nested/']) }
      @response.should eql("Copied spec/fixtures/files/Matryoshka/ => :recurse/nested/\n")
      @exit_status.should be_exit(:success)
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', ':recurse/nested/Matryoshka/', 'spec/tmp/recurse/']) }
    end
    
    it "should report success" do
      @response.should eql("Copied :recurse/nested/Matryoshka/ => spec/tmp/recurse/\n")
      @exit_status.should be_exit(:success)
    end

    it "container should have lots of files" do
      entries = Dir.entries('spec/tmp/recurse/Matryoshka').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Putin")
      entries.length.should eq(3)

      entries = Dir.entries('spec/tmp/recurse/Matryoshka/Putin').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Medvedev.txt")
      entries[3].should eq("Vladimir.txt")
      entries[4].should eq("Yeltsin")
      entries.length.should eq(5)

      entries = Dir.entries('spec/tmp/recurse/Matryoshka/Putin/Yeltsin').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Boris.txt")
      entries[3].should eq("Gorbachev")
      entries.length.should eq(4)

      entries = Dir.entries('spec/tmp/recurse/Matryoshka/Putin/Yeltsin/Gorbachev').sort
      entries[0].should eq(".")
      entries[1].should eq("..")
      entries[2].should eq("Andropov.txt")
      entries[3].should eq("Chernenko.txt")
      entries[4].should eq("Mikhail.txt")
      entries.length.should eq(5)

    end
    
  end

  after(:all) do
    FileUtils.rm_rf('spec/tmp/recurse')
  end
end
