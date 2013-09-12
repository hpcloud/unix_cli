require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:console" do
  context "when gettting console 10" do
    it "should show success message" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:console cli_test_srv1 10")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Console output for cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when gettting console nothing" do
    it "should show success message" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:console cli_test_srv1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Console output for cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when gettting console bogus lines" do
    it "should show failure message" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:console cli_test_srv1 bogus")

      rsp.stderr.should eq("Invalid number of lines specified 'bogus'\n")
      rsp.stdout.should include("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "servers:console with valid avl" do
    it "should report success" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:console cli_test_srv1 10 -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Console output for cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:console cli_test_srv1 10 -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:console cli_test_srv1 10 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
