require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Dnss command" do
  def then_expected_table(response)
    response.should match("| .*id.*|.*name.*|.*size.*|.*type.*|.*created.*|.*status.*|.*description.*|.*servers.*|\n")
    response.should match("| #{@dns1.name} *| 1 *| *|")
    response.should match("| #{@dns2.name} *| 1 *| *|")
  end

  before(:all) do
    @dns1 = DnsTestHelper.create("cli_test_dns1")
    @dns2= DnsTestHelper.create("cli_test_dns2")
  end

  context "dnss" do
    it "should report success" do
      rsp = cptr("dnss #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dnss:list" do
    it "should report success" do
      rsp = cptr("dnss:list #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dnss --bootable" do
    it "should report success" do
      rsp = cptr("dnss --bootable")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dnss with valid avl" do
    it "should report success" do
      rsp = cptr("dnss #{@dns1.name} #{@dns2.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dnss with invalid avl" do
    it "should report error" do
      rsp = cptr('dnss -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dnss -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
