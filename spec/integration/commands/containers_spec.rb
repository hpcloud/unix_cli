require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "containers command" do
  describe "with avl settings from config" do
    context "containers" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['containers']) }
        exit_status.should be_exit(:success)
      end
    end

    context "containers:list" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['containers:list']) }
        exit_status.should be_exit(:success)
      end
    end
  end
  describe "with avl settings passed in" do
    context "containers with valid avl" do
      it "should report success" do
        response, exit_status = run_command('containers -z region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "containers with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('containers -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
  end
end
