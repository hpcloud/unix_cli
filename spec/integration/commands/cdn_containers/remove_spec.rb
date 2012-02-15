require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:remove command" do

  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
    begin
      purge_containers(@hp_svc)
    rescue
      # ignore errors
    end
  end

  context "removing an existing container from the CDN" do

    before(:all) do
      @hp_svc.put_container('my-added-container')
      @hp_cdn.put_container('my-added-container')
      @response, @exit = run_command('cdn:containers:remove my-added-container').stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("Removed container 'my-added-container' from the CDN.\n")
    end
    its_exit_status_should_be(:success)

    after(:all) do
      @hp_svc.delete_container('my-added-container')
    end

  end

  context "removing a non-existent storage container from the CDN" do

    before(:all) do
      @response, @exit = run_command('cdn:containers:remove not-a-container').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have a container named 'not-a-container' on the CDN.\n")
    end
    its_exit_status_should_be(:not_found)

  end

end