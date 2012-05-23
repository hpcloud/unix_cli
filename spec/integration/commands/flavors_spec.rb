require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Flavors command" do
  describe "with avl settings from config" do
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
  describe "with avl settings passed in" do
    context "flavors with valid avl" do
      it "should report success" do
        response, exit_status = run_command('flavors -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "flavors with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('flavors -z blah').stderr_and_exit_status
        response.should eql("Unable to retrieve endpoint service url for availability zone 'blah' from service catalog. \n")
        exit_status.should be_exit(:general_error)
      end
    end
  end
end