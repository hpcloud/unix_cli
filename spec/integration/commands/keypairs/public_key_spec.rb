require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:add command" do

  before(:all) do
    @key_name = "cli_test_key1"
    @keypair = KeypairTestHelper.create(@key_name)
  end

  context "when getting good keypair" do
    it "should dump public key" do

      rsp = cptr("keypairs:public_key #{@key_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq(@keypair.public_key)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when getting bad keypair" do
    it "should show error message" do

      rsp = cptr("keypairs:public_key bogus")

      rsp.stderr.should eq("Cannot find a keypair matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "keypairs:add with invalid avl" do
    it "should report error" do
      rsp = cptr("keypairs:add some_key_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("keypairs:add -a bogus nameo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
