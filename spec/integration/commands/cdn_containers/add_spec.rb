require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:add command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
    begin
      purge_containers(@hp_svc)
    rescue
      # ignore errors
    end
  end

  context "putting an existing storage container on the CDN" do

    before(:all) do
      @hp_svc.put_container('my-added-container')
      @response, @exit = run_command('cdn:containers:add my-added-container').stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("Added container 'my-added-container' to the CDN.\n")
    end
    its_exit_status_should_be(:success)

    it "should have added the container to the CDN" do
      @hp_cdn.head_container('my-added-container').status.should eql(204)
    end

    after(:all) do
      @hp_cdn.delete_container('my-added-container')
      @hp_svc.delete_container('my-added-container')
    end

  end

  context "putting a non-existent storage container on the CDN" do

    before(:all) do
      @response, @exit = run_command('cdn:containers:add not-a-container').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("The container 'not-a-container' does not exist in your storage account. Please create the storage container first and then add it to the CDN.\n")
    end
    its_exit_status_should_be(:incorrect_usage)

  end

  describe "with avl settings passed in" do
    before(:all) do
      @hp_svc.put_container('my-added-container2')
      @response, @exit = run_command('cdn:containers:add my-added-container2').stdout_and_exit_status
    end
    context "cdn:containers:add with valid avl" do
      it "should report success" do
        response, exit_status = run_command('cdn:containers:add my-added-container2 -z region-a.geo-1').stdout_and_exit_status
        response.should eql("Added container 'my-added-container2' to the CDN.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "cdn:containers:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('cdn:containers:add my-added-container2 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Cdn' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
    after(:all) do
      @hp_cdn.delete_container('my-added-container2')
      @hp_svc.delete_container('my-added-container2')
    end
  end


end