require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:disassociate command" do
  before(:all) do
    @hp_svc = compute_connection
    @srv = ServerTestHelper.create('cli_test_srv1')

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @public_ip = rsp.stdout.scan(/'([^']+)/)[0][0]

    rsp = cptr('addresses:add')
    rsp.stderr.should eq("")
    @second_ip = rsp.stdout.scan(/'([^']+)/)[0][0]
  end

  context "when specifying a bad IP address" do
    it "should show error message" do
      rsp = cptr('addresses:disassociate 111.111.111.111')

      rsp.stderr.should eq("Cannot find an ip address matching '111.111.111.111'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when no server is associated" do
    it "should show success message" do
      cptr("addresses:disassociate #{@public_ip}")

      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("You don't have any server associated with address '#{@public_ip}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when specifying a good IP address" do
    it "should show success message" do
      cptr("addresses:associate #{@public_ip} #{@srv.name}")

      rsp = cptr("addresses:disassociate #{@public_ip}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@public_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with valid avl" do
    it "should report success" do
      cptr("addresses:associate #{@second_ip} #{@srv.name}")

      rsp = cptr("addresses:disassociate #{@second_ip} -z region-b.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Disassociated address '#{@second_ip}' from any server instance.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "disassociate ip with invalid avl" do
    it "should report error" do
      rsp = cptr("addresses:disassociate #{@second_ip} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:disassociate 127.0.0.1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    rsp = cptr("addresses:remove #{@public_ip}")
    rsp = cptr("addresses:remove #{@second_ip}")
  end
end
