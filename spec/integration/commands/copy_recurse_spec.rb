require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Copy command recrusive" do
  
  before(:all) do
    @hp_svc = storage_connection
  end
  
  context "copying local directory to container" do
    
    before(:all) do
      purge_container('recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev', ':recurse']) }
      sleep(10)
      @container = @hp_svc.get_container('recurse')
    end
    
    it "should report success" do
      @response.should eql("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev => :recurse/Gorbachev\n")
      @exit_status.should be_exit(:success)
    end
    
    it "container should have three files" do
      @container.body[0]['name'].should eq("Andropov.txt")
      @container.body[1]['name'].should eq("Chernenko.txt")
      @container.body[2]['name'].should eq("Mikhail.txt")
      @container.body.length.should eq(3)
    end
    
  end

  context "copying multilevel local directory to container" do
    
    before(:all) do
      purge_container('recurse')
      @hp_svc.put_container('recurse')
      @response, @exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['copy', 'spec/fixtures/files/Matryoshka/', ':recurse/nested']) }
      sleep(10)
      @container = @hp_svc.get_container('recurse')
    end
    
    it "should report success" do
      @response.should eql("Copied spec/fixtures/files/Matryoshka/ => :recurse/nested\n")
      @exit_status.should be_exit(:success)
    end
    
    it "container should have six files" do
      @container.body[0]['name'].should eq("nested/Putin/Medvedev.txt")
      @container.body[1]['name'].should eq("nested/Putin/Vladimir.txt")
      @container.body[2]['name'].should eq("nested/Putin/Yeltsin/Boris.txt")
      @container.body[3]['name'].should eq("nested/Putin/Yeltsin/Gorbachev/Andropov.txt")
      @container.body[4]['name'].should eq("nested/Putin/Yeltsin/Gorbachev/Chernenko.txt")
      @container.body[5]['name'].should eq("nested/Putin/Yeltsin/Gorbachev/Mikhail.txt")
      @container.body.length.should eq(6)
    end
    
  end

  #after(:all) { purge_container('recurse') }
end
