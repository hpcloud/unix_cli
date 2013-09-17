require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:versions" do
  context "lb:versions" do
    it "should report success" do
      rsp = cptr("lb:versions -c id,status -d X")

      rsp.stderr.should eq("")
      rsp.stdout.should match("v1.1XCURRENT\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
