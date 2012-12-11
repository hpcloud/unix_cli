require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "keypairs:private:location" do

  before(:all) do
    keypair = KeypairTestHelper.create("cli_test_key1")
    @server1 = ServerTestHelper.create("cli_test_srv1")
    keypair.private_read
    keypair.name = "#{@server1.id}"
    keypair.private_add
  end

  context "location" do
    it "should show success message" do
      rsp = cptr("keypairs:private:location cli_test_srv1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("#{ENV['HOME']}/.hpcloud/keypairs/#{@server1.id}.pem\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "location bogus" do
    it "should show failure message" do
      rsp = cptr("keypairs:private:location bogus_server")

      rsp.stderr.should eq("Cannot find a server matching 'bogus_server'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
end
