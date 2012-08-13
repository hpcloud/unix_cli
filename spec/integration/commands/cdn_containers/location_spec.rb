require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:location command" do

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

  context "for an existing CDN container" do
    before(:all) do
      @hp_svc.put_container('my-added-container')
      @hp_cdn.put_container('my-added-container')
    end
    context "getting the location" do
      before(:all) do
        @response, @exit = run_command('cdn:containers:location my-added-container').stdout_and_exit_status
      end

      it "should get the correct value" do
        cdn_uri = @hp_cdn.head_container("my-added-container").headers["X-Cdn-Uri"]
        @response.should eql(cdn_uri+"\n")
      end
      its_exit_status_should_be(:success)
    end
    after(:all) do
      @hp_svc.delete_container('my-added-container')
      @hp_cdn.delete_container('my-added-container')
    end
  end
  context "for a non-existent CDN container" do
    before(:all) do
      @response, @exit = run_command('cdn:containers:location not-a-container').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have a container named 'not-a-container' on the CDN.\n")
    end
    its_exit_status_should_be(:not_found)
  end
  describe "with avl settings passed in" do
    before(:all) do
      @hp_svc.put_container('my-added-container2')
      @hp_cdn.put_container('my-added-container2')
    end
    context "cdn:containers:location with valid avl" do
      it "should report success" do
        response, exit_status = run_command('cdn:containers:location my-added-container2 -z region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "cdn:containers:location with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('cdn:containers:location my-added-container2 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Cdn' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
    after(:all) do
      @hp_cdn.delete_container('my-added-container2')
      @hp_svc.delete_container('my-added-container2')
    end
  end

end
