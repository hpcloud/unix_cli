require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:get command" do

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
    context "getting the value of a valid attribute" do
      before(:all) do
        run_command('cdn:containers:set my-added-container X-Ttl 900').stdout_and_exit_status
        @response, @exit = run_command('cdn:containers:get my-added-container X-Ttl').stdout_and_exit_status
      end

      it "should get the correct value" do
        @response.should eql("900\n")
      end
      its_exit_status_should_be(:success)
    end
    context "getting the value of an invalid attribute" do
      before(:all) do
        @response, @exit = run_command('cdn:containers:get my-added-container blah').stderr_and_exit_status
      end

      it "should show error message" do
        @response.should eql("The value of the attribute 'blah' cannot be retrieved. The allowed attributes are 'X-Ttl, X-Cdn-Uri, X-Cdn-Enabled, X-Log-Retention'.\n")
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
      @response, @exit = run_command('cdn:containers:get not-a-container blah').stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You don't have a container named 'not-a-container' on the CDN.\n")
    end
    its_exit_status_should_be(:not_found)

  end

end