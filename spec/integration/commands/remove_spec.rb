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
      #### Swift does not have acls, so it just cannot see the container
      it "should exit with access denied" do
        @file_name='spec/fixtures/files/Matryoshka/Putin/Medvedev.txt'
        cptr("containers:add -a secondary :notmycontainer")
        cptr("copy -a secondary #{@file_name} :notmycontainer")

        rsp = cptr("rm :notmycontainer/#{@file_name}")

        rsp.stderr.should eq("You don't have a container named 'notmycontainer'\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
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
          after(:all) { Connection.instance.clear_options() }
        end
        after(:all) do
          purge_container('my_container')
        end
      end
    end

  end

  context "removing a container" do
    def cli
      @cli ||= HP::Cloud::CLI.new
    end

    context "when user owns container and it exists" do
      before(:all) do
        @hp_svc.put_container('container_to_remove')
      end

      it "should ask for confirmation to delete" do
        exit_status = :success
        $stdout.should_receive(:print).with("Are you sure you want to remove the container 'container_to_remove'? ")
        $stdin.should_receive(:gets).and_return('y')
        $stdout.should_receive(:puts).with("Removed container 'container_to_remove'.")
        begin
          cli.send('remove', ':container_to_remove')
        rescue SystemExit => system_exit # catch any exit calls
          exit_status = system_exit.status
        end
        exit_status.should be_exit(:success)
      end

      it "should remove container" do
        lambda{ @hp_svc.get_container('container_to_remove') }.should raise_error(Fog::Storage::HP::NotFound)
      end

      after(:all) { purge_container('container_to_remove') }

    end

    context "when container is not empty" do
      before(:all) do
        create_container_with_files('non_empty_container', 'foo.txt')
      end
      context "when force option is not used" do

        it "should not remove container" do
          exit_status = :success
          $stdout.should_receive(:print).with("Are you sure you want to remove the container 'non_empty_container'? ")
          $stdin.should_receive(:gets).and_return('y')
          $stderr.should_receive(:puts).with("The container 'non_empty_container' is not empty. Please use -f option to force deleting a container with objects in it.")
          begin
            cli.send('remove', ':non_empty_container')
          rescue SystemExit => system_exit # catch any exit calls
            exit_status = system_exit.status
          end
          exit_status.should be_exit(:general_error)
        end
      end
      context "when force option is used" do
        before(:all) do
          @response, @exit = run_command('remove -f :non_empty_container').stdout_and_exit_status
        end
        it "should show success message" do
          @response.should eql("Removed container 'non_empty_container'.\n")
        end

        it "should remove container" do
          lambda{ @hp_svc.get_container('non_empty_container') }.should raise_error(Fog::Storage::HP::NotFound)
        end

        it "should have success exit status" do
          @exit.should be_exit(:success)
        end
      end

      after(:all) { purge_container('non_empty_container') }

    end

  end
end
