require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "buckets:add command" do

  def cli
    @cli ||= HP::Scalene::CLI.new
  end

  before(:all) do
    purge_buckets
    @kvs = storage_connection
    @other_user = storage_connection(:secondary)
  end

  context "when creating a new valid bucket" do
    
    before(:all) do
      @response, @exit = run_command('buckets:add my-added-bucket').stdout_and_exit_status
    end
    
    it "should show success message" do
      @response.should eql("Created bucket 'my-added-bucket'.\n")
    end
    its_exit_status_should_be(:success)
    
    it "should have created the bucket" do
      resp = @kvs.head_container('my-added-bucket').status.should eql(204)
    end
    
    after(:all) { purge_bucket('my-added-bucket') }
    
  end

  #### It is not an exception to create a bucket whic already exists in Swift
  pending "when creating a bucket which already exists" do
    
    before(:all) do
      @kvs.put_container('already-a-bucket')
      @response, @exit = run_command('buckets:add already-a-bucket').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.\n")
    end
    its_exit_status_should_be(:permission_denied)
    
    after(:all) { purge_bucket('already-a-bucket') }
    
  end
  
  context "when creating a bucket with invalid characters in the name" do
    
    before(:all) do
      @response, @exit = run_command('buckets:add my/bucket --force').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("The bucket name specified is invalid. Please see API documentation for valid naming guidelines.\n")
    end
    its_exit_status_should_be(:permission_denied)
    
  end
  
  context "when creating a bucket whose name is valid, but not valid virtual host" do
    
    it "should present interactive prompt to verify behavior" do
      $stdout.should_receive(:print).with('Specified bucket name is not a valid virtualhost, continue anyway? ')
      $stdin.should_receive(:gets).and_return('n')
      begin
        cli.send('buckets:add', 'UPPERCASE')
      rescue SystemExit => system_exit # catch any exit calls
        exit_status = system_exit.status
      end
    end
    
  end

end