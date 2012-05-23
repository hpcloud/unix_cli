require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Config command" do
  context "config" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['config']) }
      exit_status.should be_exit(:success)
    end
  end
end