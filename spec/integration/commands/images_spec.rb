require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Images command" do
  describe "with avl settings from config" do
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

  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        response, exit_status = run_command('images -z az-1.region-a.geo-1').stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "images with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('images -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
