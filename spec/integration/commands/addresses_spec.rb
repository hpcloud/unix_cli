require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Addresses command" do
  context "addresses" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['addresses']) }
      exit_status.should be_exit(:success)
    end
  end

  context "addresses:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['addresses:list']) }
      exit_status.should be_exit(:success)
    end
  end
end