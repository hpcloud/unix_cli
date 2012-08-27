require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:set command" do

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
    context "setting an attribute with a valid value" do
      before(:all) do
        @response, @exit = run_command('cdn:containers:set my-added-container X-Ttl 900').stdout_and_exit_status
      end

      it "should show success message" do
        @response.should eql("The attribute 'X-Ttl' with value '900' was set on CDN container 'my-added-container'.\n")
      end
      its_exit_status_should_be(:success)
      it "should have set the correct value" do
        response = @hp_cdn.head_container('my-added-container')
        response.headers['X-Ttl'].should eql("900")
      end
    end
    context "setting an attribute with an invalid value" do
      before(:all) do
        @response, @exit = run_command('cdn:containers:set my-added-container X-Ttl 1').stderr_and_exit_status
      end

      it "should show error message" do
        @response.should include("400 Bad Request")
      end
      its_exit_status_should_be(:incorrect_usage)
    end
    context "setting an invalid attribute" do
      before(:all) do
        @response, @exit = run_command('cdn:containers:set my-added-container blah 1').stderr_and_exit_status
      end

      it "should show error message" do
        @response.should eql("The attribute 'blah' cannot be set. The allowed attributes are 'X-Ttl, X-Cdn-Uri, X-Cdn-Enabled, X-Log-Retention'.\n")
      end
      its_exit_status_should_be(:incorrect_usage)
    end
    after(:all) do
      @hp_svc.delete_container('my-added-container')
      @hp_cdn.delete_container('my-added-container')
    end
  end
  context "for a non-existent CDN container" do
    before(:all) do
      @response, @exit = run_command('cdn:containers:set not-a-container blah 1').stderr_and_exit_status
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
    context "cdn:containers:set with valid avl" do
      it "should report success" do
        response, exit_status = run_command('cdn:containers:set my-added-container2 X-Ttl 900 -z region-a.geo-1').stdout_and_exit_status
        response.should eql("The attribute 'X-Ttl' with value '900' was set on CDN container 'my-added-container2'.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "cdn:containers:set with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('cdn:containers:set my-added-container2 X-Ttl 900 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Cdn' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
    after(:all) do
      @hp_cdn.delete_container('my-added-container2')
      @hp_svc.delete_container('my-added-container2')
    end
  end

end
