require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "list command" do
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('my_container')
  end

  describe "with avl settings from config" do
    context "list" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['list']) }
        exit_status.should be_exit(:success)
      end
    end

    context "list container contents" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['list', ':my_container']) }
        exit_status.should be_exit(:success)
      end
    end
  end

  describe "with avl settings passed in" do
    context "list container with valid avl" do
      it "should report success" do
        response, exit_status = run_command('list :my_container -z region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "list container with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('list :my_container -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
  end

  after(:all) { purge_container('my_container') }

end
