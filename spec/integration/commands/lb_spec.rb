require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "lb" do
  before(:all) do
    rsp = cptr("lb:add cli_test_lb1 ROUND_ROBIN HTTP 80 -n 10.3.2.1:81")
    rsp = cptr("lb:add cli_test_lb2 LEAST_CONNECTIONS TCP 443 -n 10.3.2.2:444")
  end

  context "lb" do
    it "should report success" do
      rsp = cptr("lb -c name,algorithm,protocol,port -d X cli_test_lb1 cli_test_lb2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("cli_test_lb1XROUND_ROBINXHTTPX80\ncli_test_lb2XLEAST_CONNECTIONSXTCPX443\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lb:list" do
    it "should report success" do
      rsp = cptr("lb:list -c name,algorithm,protocol,port -d X cli_test_lb1 cli_test_lb2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("cli_test_lb1XROUND_ROBINXHTTPX80\ncli_test_lb2XLEAST_CONNECTIONSXTCPX443\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lb with valid avl" do
    it "should report success" do
      rsp = cptr("lb -c name,algorithm,protocol,port -d X cli_test_lb1 cli_test_lb2 -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("cli_test_lb1XROUND_ROBINXHTTPX80\ncli_test_lb2XLEAST_CONNECTIONSXTCPX443\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "lb with invalid avl" do
    it "should report error" do
      rsp = cptr('lb -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Load Balancer' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lb -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
