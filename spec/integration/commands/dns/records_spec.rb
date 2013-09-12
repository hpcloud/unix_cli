require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "dns:records command" do
  before(:all) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "dns:records" do
    it "should report success" do
      rsp = cptr("dns:records:add #{@dns1.name} list.clitest1.com. A 10.3.3.3")
      rsp.stderr.should eq("")

      rsp = cptr("dns:records -c name,type,data -d X #{@dns1.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should match("list.clitest1.com.XAX10.3.3.3")
      rsp.exit_status.should be_exit(:success)
    end
  end

  after(:each) do
    cptr("dns:records:remove #{@dns1.name} list.clitest1.com.")
  end
end
