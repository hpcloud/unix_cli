require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Images command" do
  context "images" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['images']) }
      exit_status.should be_exit(:success)
    end
  end

  context "images:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['images:list']) }
      exit_status.should be_exit(:success)
    end
  end
end