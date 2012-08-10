require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "containers:add command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
    begin
      purge_containers(@hp_svc)
    rescue
      # ignore errors
    end
    @other_user = storage_connection(:secondary)
  end

  context "when creating a new valid container" do
    
    before(:all) do
      @response, @exit = run_command('containers:add my-added-container').stdout_and_exit_status
    end
    
    it "should show success message" do
      @response.should eql("Created container 'my-added-container'.\n")
    end
    its_exit_status_should_be(:success)
    
    it "should have created the container" do
      resp = @hp_svc.head_container('my-added-container').status.should eql(204)
    end
    
    after(:all) { purge_container('my-added-container') }
    
  end

  context "when creating a container which already exists" do
    
    before(:all) do
      @hp_svc.put_container('already-a-container')
      @response, @exit = run_command('containers:add already-a-container').stdout_and_exit_status
    end
    
    it "should show exists message" do
      @response.should eql("Container 'already-a-container' already exists.\n")
    end

    after(:all) { purge_container('already-a-container') }

  end
  
  context "when creating a container with invalid characters in the name" do
    
    before(:all) do
      @response, @exit = run_command('containers:add my/container --force').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("The container name specified is invalid. Please see API documentation for valid naming guidelines.\n")
    end
    its_exit_status_should_be(:permission_denied)
    
  end
  
  context "when creating a container whose name is valid, but not valid virtual host" do
    it "should present interactive prompt to verify behavior" do
      $stdout.should_receive(:print).with('Specified container name is not a valid virtualhost, continue anyway? [y/n] ')
      $stdin.should_receive(:gets).and_return('n')
      begin
        cli.send('containers:add', 'UPPERCASE')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end
  end

  describe "with avl settings passed in" do
    context "add with valid avl" do
      it "should report success" do
        response, exit_status = run_command('containers:add my-added-container2 -z region-a.geo-1').stdout_and_exit_status
        response.should eql("Created container 'my-added-container2'.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('containers:add my-added-container2 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
    after(:all) { purge_container('my-added-container2') }
  end


end
