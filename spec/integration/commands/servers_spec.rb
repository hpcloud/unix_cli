require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Servers command" do
  context "servers" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['servers']) }
      exit_status.should be_exit(:success)
    end
  end

  context "servers:list" do
    it "should report success" do
      response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['servers:list']) }
      exit_status.should be_exit(:success)
    end
  end
end