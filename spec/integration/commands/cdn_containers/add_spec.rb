require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:add command" do

  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
  end

  context "putting an existing storage container on the CDN" do
    it "should show success message" do
      cptr('containers:remove -f my-added-container')
      cptr('containers:add my-added-container')

      rsp = cptr('cdn:containers:add my-added-container')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Added container 'my-added-container' to the CDN.\n")
      rsp.exit_status.should be_exit(:success)
      @hp_cdn.head_container('my-added-container').status.should eql(204)
    end

    after(:all) do
      @hp_cdn.delete_container('my-added-container')
      @hp_svc.delete_container('my-added-container')
    end
  end

  context "putting an multiple storage container on the CDN" do
    it "should show success message" do
      @hp_svc.put_container('tainer1')
      @hp_svc.put_container('tainer2')
      cptr('containers:remove -f tainer1')
      cptr('containers:add tainer1')
      cptr('containers:remove -f tainer2')
      cptr('containers:add tainer2')

      rsp = cptr('cdn:containers:add tainer1 tainer2')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Added container 'tainer1' to the CDN.\nAdded container 'tainer2' to the CDN.\n")
      rsp.exit_status.should be_exit(:success)
      @hp_cdn.head_container('tainer1').status.should eql(204)
      @hp_cdn.head_container('tainer2').status.should eql(204)
    end

    after(:all) do
      @hp_cdn.delete_container('tainer1')
      @hp_svc.delete_container('tainer1')
      @hp_cdn.delete_container('tainer2')
      @hp_svc.delete_container('tainer2')
    end
  end

  context "putting a non-existent storage container on the CDN" do
    it "should show error message" do
      rsp = cptr('cdn:containers:add not-a-container')

      rsp.stderr.should eq("The container 'not-a-container' does not exist in your storage account. Please create the storage container first and then add it to the CDN.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "cdn:containers:add with valid avl" do
    it "should report success" do
      @hp_svc.put_container('my-added-container2')
      cptr('containers:remove -f my-added-container2')
      cptr('containers:add my-added-container2')
      rsp = cptr('cdn:containers:add my-added-container2')
      rsp.stderr.should eq("")

      rsp = cptr('cdn:containers:add my-added-container2 -z region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should eql("Added container 'my-added-container2' to the CDN.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers:add with invalid avl" do
    it "should report error" do
      rsp = cptr('cdn:containers:add my-added-container2 -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("cdn:containers:add my-added-container2 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @hp_cdn.delete_container('my-added-container2')
    @hp_svc.delete_container('my-added-container2')
  end
end
