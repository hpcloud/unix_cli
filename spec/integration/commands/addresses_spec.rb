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
  describe "with avl settings passed in" do
    context "addresses with valid avl" do
      it "should report success" do
        response, exit_status = run_command('addresses -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "addresses with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('addresses -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end
end