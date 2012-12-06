require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:ssh" do
  before(:all) do
    KeypairTestHelper.create("cli_test_key1")
    ServerTestHelper.create("cli_test_srv1")
  end

  context "when calling ssh" do
    it "should show success message" do

      rsp = cptr("servers:ssh cli_test_srv1", ["yes", "exit"])

puts '=========================================='
puts rsp.stdout
puts '=========================================='
      rsp.stderr.should eq("")
      rsp.stdout.should include("Connected to cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when gettting ssh bogus lines" do
    it "should show failure message" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:ssh cli_test_srv1 -k key.pem", ["exit"])

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connected to cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:ssh with valid avl" do
    it "should report success" do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:ssh cli_test_srv1 -z az-1.region-a.geo-1", ["exit"])

      rsp.stderr.should eq("")
      rsp.stdout.should include("Connected to cli_test_srv1:\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:ssh cli_test_srv1 10 -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:ssh cli_test_srv1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
