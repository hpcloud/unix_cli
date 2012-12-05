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

  context "add bogus" do
    it "should show failure message" do
      rsp = cptr("keypairs:private:add cli_test_key4 ./bogus.pem")

      rsp.stderr.should eq("No such file or directory - ./bogus.pem\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
end
