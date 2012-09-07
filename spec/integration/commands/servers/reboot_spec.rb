require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:reboot command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    server = ServerTestHelper.create("cli_test_srv1")
  end

  ### Server creation returns status "failed to spawn", hence test fails
  pending "when soft rebooting server" do
    it "should show success message" do
      rsp = cptr("servers:reboot #{@server_name}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Soft rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  pending "when hard rebooting server" do
    it "should show success message" do
      rsp = cptr("servers:reboot #{@server_name} -h")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Hard rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:reboot with valid avl" do
    it "should report success" do
      rsp = cptr("servers:reboot #{@server_name} -z az-1.region-a.geo-1")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Soft rebooting server '#{@server_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:reboot with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:reboot #{@server_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:reboot #{@server_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
