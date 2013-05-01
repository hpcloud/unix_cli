require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "dns:records:remove command" do
  before(:each) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "when creating dns with name description" do
    it "should show success message" do
      rsp = cptr("dns:records:add #{@dns1.name} www.clitest1.com. A 10.0.0.1")
      rsp.stderr.should eq("")

      rsp = cptr("dns:records:remove #{@dns1.name} www.clitest1.com.")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed DNS record 'www.clitest1.com.'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
