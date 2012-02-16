require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "CDN Containers command" do
  context "cdn:containers" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['cdn:containers']) }
      exit_status.should be_exit(:success)
    end
  end

  context "cdn:containers:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['cdn:containers:list']) }
      exit_status.should be_exit(:success)
    end
  end
end