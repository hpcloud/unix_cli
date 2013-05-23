require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Networks command" do
  def then_expected_table(response)
    response.should match("#{@network1.name},")
    response.should match("#{@network2.name},")
  end

  before(:all) do
    @network1 = NetworkTestHelper.create("cli_test_network1")
    @network2= NetworkTestHelper.create("cli_test_network2")
  end

  context "networks" do
    it "should report success" do
      rsp = cptr("networks -d , #{@network1.name} #{@network2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "networks:list" do
    it "should report success" do
      rsp = cptr("networks:list -d , #{@network1.name} #{@network2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "networks with valid avl" do
    it "should report success" do
      rsp = cptr("networks -d , #{@network1.name} #{@network2.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "networks with invalid avl" do
    it "should report error" do
      rsp = cptr('networks -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("networks -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
