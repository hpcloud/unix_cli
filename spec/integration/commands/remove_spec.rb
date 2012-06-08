require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Remove command" do

  before(:all) do
    @hp_svc = storage_connection
  end

  context "removing an object from container" do

    before(:all) do
      purge_container('my_container')
      create_container_with_files('my_container', 'foo.txt')
    end

    context "when object does not exist" do
      it "should exit with object not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['remove', ':my_container/nonexistant.txt']) }
        response.should eql("You don't have a object named 'nonexistant.txt'.\n")
        exit_status.should be_exit(:not_found)
      end
    end

    context "when container does not exist" do
      it "should exit with container not found" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['remove', ':nonexistant_container']) }
        response.should eql("You don't have a container named 'nonexistant_container'\n")
        exit_status.should be_exit(:not_found)
      end
    end

    context "when removing an object that isn't controlled by the user" do
      before(:all) do
        @hp_svc_other_user = storage_connection(:secondary)
        @hp_svc_other_user.put_container('notmycontainer')
        @hp_svc_other_user.put_object('notmycontainer', 'foo.txt', read_file('foo.txt'), {'Content-Type' => 'text/plain'})
        @response, @exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['rm', ':notmycontainer/foo.txt']) }
      end

      #### Swift does not have acls, so it just cannot see the container
      it "should exit with access denied" do
        @response.should eql("You don't have a container named 'notmycontainer'\n")
      end

      #### Swift does not have acls, so it just cannot see the container
      pending "should exit with denied status" do
        @exit_status.should be_exit(:permission_denied)
      end

      after(:all) do
        purge_container('notmycontainer', {:connection => @hp_svc_other_user})
      end
    end

    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['remove', '/foo/foo']) }
        response.should eql("Could not find resource '/foo/foo'. Correct syntax is :containername/objectname.\n")
        exit_status.should be_exit(:incorrect_usage)
      end
    end

    context "when object and container exist" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['remove', ':my_container/foo.txt']) }
        response.should eql("Removed object ':my_container/foo.txt'.\n")
        exit_status.should be_exit(:success)
      end
      describe "with avl settings passed in" do
        before(:all) do
          purge_container('my_container')
          create_container_with_files('my_container', 'foo.txt')
        end
        context "remove with valid avl" do
          it "should report success" do
            response, exit_status = run_command('remove :my_container/foo.txt -z region-a.geo-1').stdout_and_exit_status
            response.should eql("Removed object ':my_container/foo.txt'.\n")
            exit_status.should be_exit(:success)
          end
        end
        context "remove with invalid avl" do
          it "should report error" do
            response, exit_status = run_command('remove :my_container/foo.txt -z blah').stderr_and_exit_status
            response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
            exit_status.should be_exit(:general_error)
          end
        end
        after(:all) do
          purge_container('my_container')
        end
      end
    end

  end


end