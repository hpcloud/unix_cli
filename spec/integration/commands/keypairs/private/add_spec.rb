require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "keypairs:private:add" do

  before(:all) do
    filename = "#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key"
    FileUtils.rm_f(filename + "3.pem")
    FileUtils.rm_f(filename + "4.pem")
  end

  context "add" do
    it "should show success message" do
      rsp = cptr("keypairs:private:add cli_test_key3 #{__FILE__}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Added private key '#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key3.pem'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
