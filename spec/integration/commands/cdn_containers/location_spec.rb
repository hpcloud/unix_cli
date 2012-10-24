require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "cdn:containers:location command" do
  before(:all) do
    @hp_svc = storage_connection
    @hp_cdn = cdn_connection
    begin
      purge_containers(@hp_svc)
    rescue
      # ignore errors
    end
    @hp_svc.put_container('my-added-container2')
    @hp_cdn.put_container('my-added-container2')
  end

  context "for an existing CDN container" do
    before(:all) do
      @hp_svc.put_container('my-added-container')
      @hp_cdn.put_container('my-added-container')
    end

    context "getting the location" do
      it "should get the correct value" do
        rsp = cptr('cdn:containers:location my-added-container')

        rsp.stderr.should eq("")
        cdn_uri = @hp_cdn.head_container("my-added-container").headers["X-Cdn-Uri"]
        rsp.stdout.should eq(cdn_uri+"\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "getting the location" do
      it "should get the correct value" do
        rsp = cptr('cdn:containers:location my-added-container -s')

        rsp.stderr.should eq("")
        cdn_uri = @hp_cdn.head_container("my-added-container").headers["X-Cdn-Ssl-Uri"]
        rsp.stdout.should eq(cdn_uri+"\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    after(:all) do
      @hp_svc.delete_container('my-added-container')
      @hp_cdn.delete_container('my-added-container')
    end
  end

  context "for a non-existent CDN container" do
    it "should show error message" do
      rsp = cptr('cdn:containers:location not-a-container')

      rsp.stderr.should eq("Cannot find container ':not-a-container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "cdn:containers:location with valid avl" do
    it "should report success" do
      rsp = cptr('cdn:containers:location my-added-container2 -z region-a.geo-1')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers:location with invalid avl" do
    it "should report error" do
      rsp = cptr('cdn:containers:location my-added-container2 -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("cdn:containers:location my-added-container2 -a bogus")

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
