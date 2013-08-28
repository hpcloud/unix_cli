require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "dns:records:remove command" do
  before(:each) do
    @dnsname = "clitest1.com."
    cptr("dns:remove #{@dnsname}")
    cptr("dns:add #{@dnsname} clitest@example.com")
  end

  context "when creating dns with name description" do
    it "should show success message" do
      rsp = cptr("dns:records:add #{@dnsname} rr.clitest1.com. A 10.9.9.1")
      rsp.stderr.should eq("")
      @new_id = rsp.stdout.scan(/'([^']+)/)[2][0]

      rsp = cptr("dns:records:remove #{@dnsname} #{@new_id}")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed DNS record '#{@new_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
