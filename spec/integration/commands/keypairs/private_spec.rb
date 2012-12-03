require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:private" do

  before(:all) do
    filename = "#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key"
    FileUtils.touch(filename + "1")
    FileUtils.touch(filename + "2")
  end

  context "list" do
    it "should show success message" do
      rsp = cptr("keypairs:private")

      rsp.stderr.should eq("")
      rsp.stdout.should include("cli_test_key1")
      rsp.stdout.should include("cli_test_key2")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
