require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "dns:records:add command" do
  before(:each) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "when creating dns with name description" do
    it "should show success message" do
      rsp = cptr("dns:records:add #{@dns1.name} www.clitest1.com. A 10.0.0.1")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns record 'www.clitest1.com.' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns:records -c name,type,data -d X #{@dns1.name}")
      rsp.stdout.should match("www.clitest1.com.XAX10.0.0.1\n")
    end

    after(:each) do
      cptr("dns:record:remove #{@dns1.name} www.clitest1.com.")
    end
  end
end
