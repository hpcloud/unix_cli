require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "networks:add" do
  context "when creating network" do
    it "should show success message" do
      @networks_name = resource_name("add1")

      rsp = cptr("networks:add #{@networks_name}")

      rsp.stderr.should eq("")
      @new_networks_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created network '#{@networks_name}' with id '#{@new_networks_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:each) do
      rsp = cptr("networks:remove #{@networks_name}")
      rsp.stderr.should eq("")
    end
  end

  context "when creating networks with a name that already exists" do
    it "should fail" do
      @ds1 = NetworkTestHelper.create("cli_test_ds1")

      rsp = cptr("networks:add #{@ds1.name}")

      rsp.stderr.should eq("Network with the name '#{@ds1.name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("networks:add dsler -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
