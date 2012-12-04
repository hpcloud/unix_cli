require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:private" do

  before(:all) do
    filename = "#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key"
    FileUtils.touch(filename + "3.pem")
    FileUtils.touch(filename + "4.pem")
  end

  context "list" do
    it "should show success message" do
      rsp = cptr("keypairs:private")

      rsp.stderr.should eq("")
      rsp.stdout.should include("cli_test_key3\n")
      rsp.stdout.should include("cli_test_key4\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
