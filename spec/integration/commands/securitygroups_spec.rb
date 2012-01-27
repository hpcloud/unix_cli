require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Security Groups command" do
  context "securitygroups" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups']) }
      exit_status.should be_exit(:success)
    end
  end

  context "securitygroups:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['securitygroups:list']) }
      exit_status.should be_exit(:success)
    end
  end
end