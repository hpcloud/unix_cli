require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Lbs command" do
  def then_expected_table(response)
    response.should match("| .*id.*|.*name.*|.*size.*|.*type.*|.*created.*|.*status.*|.*description.*|.*servers.*|\n")
    response.should match("| #{@lbs1.name} *| 1 *| *|")
    response.should match("| #{@lbs2.name} *| 1 *| *|")
  end

  before(:all) do
    @lbs1 = LbTestHelper.create("cli_test_lbs1")
    @lbs2= LbTestHelper.create("cli_test_lbs2")
  end

  context "lbs" do
    it "should report success" do
      rsp = cptr("lbs #{@lbs1.name} #{@lbs2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lbs:list" do
    it "should report success" do
      rsp = cptr("lbs:list #{@lbs1.name} #{@lbs2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lbs --bootable" do
    it "should report success" do
      rsp = cptr("lbs --bootable")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lbs with valid avl" do
    it "should report success" do
      rsp = cptr("lbs #{@lbs1.name} #{@lbs2.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lbs with invalid avl" do
    it "should report error" do
      rsp = cptr('lbs -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lbs -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
