require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Dnss command" do
  before(:all) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
    @dns2= DnsTestHelper.create("clitest2.com.")
  end

  context "dns" do
    it "should report success" do
      rsp = cptr("dns -c name,ttl,email -d X #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns:list" do
    it "should report success" do
      rsp = cptr("dns:list -c name,ttl,email -d X #{@dns1.name} #{@dns2.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns with valid avl" do
    it "should report success" do
      rsp = cptr("dns -c name,ttl,email -d X #{@dns1.name} #{@dns2.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("clitest1.com.X7200Xclitest@example.com\nclitest2.com.X7200Xclitest@example.com\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "dns with invalid avl" do
    it "should report error" do
      rsp = cptr('dns -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'DNS' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dns -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
