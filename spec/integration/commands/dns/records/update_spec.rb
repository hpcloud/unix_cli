require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "dns:records:update command" do
  before(:each) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "when creating dns with name description" do
    it "should show success message" do
      rsp = cptr("dns:records:add #{@dns1.name} uu.clitest1.com. A 10.8.8.1")
      @new_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp = cptr("dns:records:update #{@dns1.name} #{@new_id} A 10.8.8.2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated DNS record '#{@new_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns:records -c name,type,data -d X #{@dns1.name}")
      rsp.stdout.should match("uu.clitest1.com.XAX10.8.8.2\n")
    end

    after(:each) do
      cptr("dns:record:remove #{@dns1.name} #{@new_id}")
    end
  end
end
