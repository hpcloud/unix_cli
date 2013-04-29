require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "dns:records command" do
  before(:all) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "dns:records" do
    it "should report success" do
      rsp = cptr("dns:records -c name,type,data -d X #{@dns1.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should match("akam.net.")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
