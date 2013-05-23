require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Routers command" do
  def then_expected_table(response)
    response.should match(",#{@router1.name},up,ACTIVE,#{@network.id}")
  end

  before(:all) do
    @router1 = RouterTestHelper.create("routerone")
    @network = NetworkTestHelper.create("Ext-Net")
  end

  context "routers" do
    it "should report success" do
      rsp = cptr("routers -d , #{@router1.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "routers:list" do
    it "should report success" do
      rsp = cptr("routers:list -d , #{@router1.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "routers with valid avl" do
    it "should report success" do
      rsp = cptr("routers -d , #{@router1.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "routers with invalid avl" do
    it "should report error" do
      rsp = cptr('routers -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
