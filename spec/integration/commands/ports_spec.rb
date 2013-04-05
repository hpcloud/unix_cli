require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Ports command" do
  def then_expected_table(response)
    response.should match("#{@port1.name},")
    response.should match("#{@port2.name},")
  end

  before(:all) do
    @port1 = PortTestHelper.create("cli_test_port1")
    @port2 = PortTestHelper.create("cli_test_port2")
  end

  context "ports" do
    it "should report success" do
      rsp = cptr("ports -d , #{@port1.name} #{@port2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "ports:list" do
    it "should report success" do
      rsp = cptr("ports:list -d , #{@port1.name} #{@port2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "ports with valid avl" do
    it "should report success" do
      rsp = cptr("ports -d , #{@port1.name} #{@port2.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "ports with invalid avl" do
    it "should report error" do
      rsp = cptr('ports -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("ports -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
