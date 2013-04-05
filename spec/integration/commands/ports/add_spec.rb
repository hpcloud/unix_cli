require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "ports:add" do
  before(:each) do
    @network1 = NetworkTestHelper.create("cli_test_network1", true)
  end

  context "when creating port" do
    it "should show success message" do
      @ports_name = resource_name("add1")

      rsp = cptr("ports:add #{@ports_name} #{@network1.name}")

      rsp.stderr.should eq("")
      @new_ports_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created port '#{@ports_name}' with id '#{@new_ports_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    after(:each) do
      rsp = cptr("ports:remove #{@ports_name}")
      rsp.stderr.should eq("")
    end
  end

  context "when creating ports with a name that already exists" do
    it "should fail" do
      @sot1 = PortTestHelper.create("cli_test_ports1")

      rsp = cptr("ports:add #{@sot1.name} #{@network1.name}")

      rsp.stderr.should eq("Port with the name '#{@sot1.name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("ports:add sotler #{@network1.name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
