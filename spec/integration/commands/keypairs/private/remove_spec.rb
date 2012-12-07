require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "keypairs:private:remove" do
  context "remove" do
    it "should show success message" do
      filename = "#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key"
      FileUtils.touch(filename + "3.pem")

      rsp = cptr("keypairs:private:remove cli_test_key3")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed private key '#{ENV['HOME']}/.hpcloud/keypairs/cli_test_key3.pem'.\n")
      rsp.exit_status.should be_exit(:success)
      File.exists?(filename + "3.pem").should be_false
    end
  end

  context "remove bogus" do
    it "should show failure message" do
      rsp = cptr("keypairs:private:remove bogus")

      rsp.stderr.should eq("No such file or directory - #{ENV['HOME']}/.hpcloud/keypairs/bogus.pem\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
end
