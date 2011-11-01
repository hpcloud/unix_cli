require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Flavors command" do
  context "flavors" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['flavors']) }
      exit_status.should be_exit(:success)
    end
  end

  context "flavors:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['flavors:list']) }
      exit_status.should be_exit(:success)
    end
  end
end