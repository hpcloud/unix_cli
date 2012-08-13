require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "containers:remove command" do

  before(:all) do
    @hp_svc = storage_connection
    @other_user = storage_connection(:secondary)
  end

  context "when container does not exist" do
    
    before(:all) do
      @response, @exit_status = run_command('containers:remove :my_nonexistant_container').stderr_and_exit_status
    end
    
    it "should show error message" do
      @response.should eql("You don't have a container named 'my_nonexistant_container'.\n")
    end
    
    it "should have failed exit status" do
      @exit_status.should be_exit(:not_found)
    end
    
  end
  
  context "when user doesn't have permissions to remove" do
    
    before(:all) do
      @other_user.put_container('other_users_container')
      @response, @exit_status = run_command('containers:remove :other_users_container').stderr_and_exit_status
    end
    
    it "should show error message" do
      #### Swift does not have acls, so it just cannot see the container
      @response.should eql("You don't have a container named 'other_users_container'.\n")
    end
    
    #### Swift does not have acls, so it just cannot see the container
    pending "should exit with denied status" do
      @exit_status.should be_exit(:permission_denied)
    end
    
    after(:all) do
      purge_container('other_users_container', :connection => @other_user)
    end
    
  end
  
  context "when user owns container and it exists" do
    
    before(:all) do
      @hp_svc.put_container('container_to_remove')
      @response, @exit = run_command('containers:remove :container_to_remove').stdout_and_exit_status
    end
    
    it "should show success message" do
      @response.should eql("Removed container 'container_to_remove'.\n")
    end
    
    it "should remove container" do
      lambda{ @hp_svc.get_container('container_to_remove') }.should raise_error(Fog::Storage::HP::NotFound)
    end
    
    it "should have success exit status" do
      @exit.should be_exit(:success)
    end
    
    after(:all) { purge_container('container_to_remove') }
    
  end

  context "when container is not empty" do
    before(:all) do
      create_container_with_files('non_empty_container', 'foo.txt')
    end
    context "when force option is not used" do
      before(:all) do
        @response, @exit = run_command('containers:remove :non_empty_container').stderr_and_exit_status
      end
      it "should show error message" do
        @response.should eql("The container 'non_empty_container' is not empty. Please use -f option to force deleting a container with objects in it.\n")
      end

      it "should not remove container" do
        @hp_svc.get_container('non_empty_container').status.should eql(200)
      end

      it "should have error exit status" do
        @exit.should be_exit(:general_error)
      end

    end
    context "when force option is used" do
      before(:all) do
        @response, @exit = run_command('containers:remove -f :non_empty_container').stdout_and_exit_status
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

  describe "with avl settings passed in" do
    before(:all) do
      @hp_svc.put_container('my-added-container2')
    end
    context "remove with valid avl" do
      it "should report success" do
        response, exit_status = run_command('containers:remove my-added-container2 -z region-a.geo-1').stdout_and_exit_status
        response.should eql("Removed container 'my-added-container2'.\n")
        exit_status.should be_exit(:success)
      end
    end
    context "remove with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('containers:remove my-added-container2 -z blah').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
  end

end
