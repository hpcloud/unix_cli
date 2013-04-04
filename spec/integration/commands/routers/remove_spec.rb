require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "routers:remove command" do
  before(:each) do
    @router_name = "routerone"
  end

  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Routers.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting router with name" do
    it "should succeed" do
      @router = RouterTestHelper.create(@router_name, false)

      rsp = cptr("routers:remove #{@router_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed router '#{@router_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@router.id)
    end
  end

  context "routers:remove with valid avl" do
    it "should be successful" do
      @router = RouterTestHelper.create(@router_name, false)

      rsp = cptr("routers:remove #{@router.id} -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed router '#{@router.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@router.id)
    end
  end

  context "routers:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("routers:remove #{@router_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "routers:remove with invalid router" do
    it "should report error" do
      rsp = cptr("routers:remove bogus")

      rsp.stderr.should eq("Cannot find a router matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
