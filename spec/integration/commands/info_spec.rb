require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Info command" do
  it "should display banner and current version" do
    rsp = cptr('info')

    rsp.stderr.should eq("")
    rsp.stdout.should include('Version:')
    rsp.exit_status.should be_exit(:success)
  end
end
