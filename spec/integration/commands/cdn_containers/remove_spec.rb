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

  context "removing an existing CDN container" do

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

  context "removing a non-existent CDN container" do

    before(:all) do
      @response, @exit = run_command('cdn:containers:remove not-a-container').stderr_and_exit_status
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
    context "cdn:containers:remove with valid avl" do
      it "should report success" do
        response, exit_status = run_command('cdn:containers:remove my-added-container2 -z region-a.geo-1').stdout_and_exit_status
        response.should eql("Removed container 'my-added-container2' from the CDN.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "cdn:containers:remove with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('cdn:containers:remove my-added-container2 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'CDN' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
    after(:all) do
      @hp_svc.delete_container('my-added-container2')
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("cdn:containers:remove -a bogus somecontainer")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
