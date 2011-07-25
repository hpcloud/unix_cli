require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "containers:add command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    purge_containers
    @hp_svc = storage_connection
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

  #### It is not an exception to create a container whic already exists in Swift
  pending "when creating a container which already exists" do
    
    before(:all) do
      @hp_svc.put_container('already-a-container')
      @response, @exit = run_command('containers:add already-a-container').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("The requested container name is not available. The container namespace is shared by all users of the system. Please select a different name and try again.\n")
    end
    its_exit_status_should_be(:permission_denied)
    
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
      $stdout.should_receive(:print).with('Specified container name is not a valid virtualhost, continue anyway? ')
      $stdin.should_receive(:gets).and_return('n')
      begin
        cli.send('containers:add', 'UPPERCASE')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end
    
  end

end