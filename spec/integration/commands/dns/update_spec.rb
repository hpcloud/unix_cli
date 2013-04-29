require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "dns:update command" do
  before(:all) do
    @dns9 = DnsTestHelper.create("clitest9.com.")
  end

  context "dns:update" do
    it "should report success" do
      rsp = cptr("dns:update -e start@update.com -t 7200 #{@dns9.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated DNS domain '#{@dns9.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns -c name,email,ttl -d X #{@dns9.name}")
      rsp.stdout.should eq("#{@dns9.name}Xstart@update.comX7200\n")

      rsp = cptr("dns:update -e finish@update.com -t 7222 #{@dns9.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Updated DNS domain '#{@dns9.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns -c name,email,ttl -d X #{@dns9.name}")
      rsp.stdout.should eq("#{@dns9.name}Xfinish@update.comX7222\n")
    end
  end
end
