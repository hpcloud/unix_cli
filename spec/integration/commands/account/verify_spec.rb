require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "account:verify" do
  context "account:verify with good file" do
    it "should report success" do
      rsp = cptr("account:verify secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Verifying 'secondary' account...\nConnected to 'secondary' successfully\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "account:verify with nonexistent file" do
    it "should report error" do
      rsp = cptr("account:verify bogus")

      rsp.stderr.should eq("Could not find account file: #{ENV['HOME']}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "account:verify with bad file" do
    it "should report error" do
      rsp = cptr("account:copy secondary temporary")
      rsp.stderr.should eq("")
      rsp = cptr("account:update temporary secret_key=garbage")
      rsp.stderr.should eq("")

      rsp = cptr("account:verify temporary")

      rsp.stderr.should include("Account verification failed. Error connecting to the service endpoint at: ")
      rsp.stdout.should eq("Verifying 'temporary' account...\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
end
