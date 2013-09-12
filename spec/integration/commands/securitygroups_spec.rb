require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Security Groups command" do
  context "securitygroups" do
    it "should report success" do
      rsp = cptr('securitygroups')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups with bogus argument" do
    it "should report success" do
      rsp = cptr('securitygroups bogusbogus')
      rsp.stderr.should eq("")
      rsp.stdout.should eq("There are no security groups that match the provided arguments\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:list" do
    it "should report success" do
      rsp = cptr('securitygroups:list')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "securitygroups with valid avl" do
    it "should report success" do
      rsp = cptr('securitygroups -z region-b.geo-1')
      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end

    after(:all) { Connection.instance.clear_options() }
  end

  context "securitygroups with invalid avl" do
    it "should report error" do
      rsp = cptr('securitygroups -z blah')
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("securitygroups -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
