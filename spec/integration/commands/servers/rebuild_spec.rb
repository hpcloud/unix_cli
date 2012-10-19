require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:rebuild command" do
  context "when soft rebuilding server" do
    it "should show success message" do
      @server_name = "cli_test_srv5"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:rebuild #{@server_name}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Server '#{@server_name}' being rebuilt.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when hard rebuilding server" do
    it "should show success message" do
      @server_name = "cli_test_srv7"
      server = ServerTestHelper.create(@server_name)

      rsp = cptr("servers:rebuild #{@server_name}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Server '#{@server_name}' being rebuilt.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:rebuild with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:rebuild server_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:rebuild server_name -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
