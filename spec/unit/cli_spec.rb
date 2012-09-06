require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Built-in help for all commands" do
  it "should list active tasks" do
    rsp = cptr('help')

    rsp.stderr.should eq("")
    rsp.stdout.should include('Tasks:')
    rsp.exit_status.should be_exit(:success)
  end
end

describe "Built-in help for a single command" do
  it "should show usage" do
    rsp = cptr('help copy')

    rsp.stderr.should eq("")
    rsp.stdout.should include('Usage:')
    rsp.exit_status.should be_exit(:success)
  end
end
