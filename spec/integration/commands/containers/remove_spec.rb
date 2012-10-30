require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "containers:remove command" do

  before(:all) do
    @hp_svc = storage_connection
  end

  context "when container does not exist" do
    it "should show error message" do
      rsp = cptr('containers:remove :my_nonexistant_container')

      rsp.stderr.should eq("You don't have a container named ':my_nonexistant_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
    
  end
  
  context "when user doesn't have permissions to remove" do
    it "should show error message" do
      cptr('containers:add -z secondary other_users_container')
      rsp = cptr("containers:remove :other_users_container")
      rsp.stderr.should eq("You don't have a container named ':other_users_container'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
  
  context "when bad container name" do
    it "should report error" do
      rsp = cptr("containers:remove :bogustotally")

      rsp.stderr.should eq("You don't have a container named ':bogustotally'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when user owns container and it exists" do
    it "should show success message" do
      @hp_svc.put_container('container_to_remove')

      rsp = cptr('containers:remove :container_to_remove')

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed container ':container_to_remove'.\n")
      rsp.exit_status.should be_exit(:success)
      lambda{ @hp_svc.get_container('container_to_remove') }.should raise_error(Fog::Storage::HP::NotFound)
    end
    
    after(:all) { purge_container('container_to_remove') }
    
  end

  context "when container is not empty" do
    before(:all) do
      create_container_with_files('non_empty_container', 'foo.txt')
    end
    context "when force option is not used" do
      it "should show error message" do
        rsp = cptr('containers:remove :non_empty_container')

        rsp.stderr.should eq("The container ':non_empty_container' is not empty. Please use -f option to force deleting a container with objects in it.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:conflicted)
        @hp_svc.get_container('non_empty_container').status.should eql(200)
      end

    end

    context "when force option is used" do
      it "should show success message" do
        rsp = cptr('containers:remove -f :non_empty_container')

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Removed container ':non_empty_container'.\n")
        rsp.exit_status.should be_exit(:success)
        lambda{ @hp_svc.get_container('non_empty_container') }.should raise_error(Fog::Storage::HP::NotFound)
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
        rsp = cptr('containers:remove my-added-container2 -z region-a.geo-1')

        rsp.stderr.should eq("")
        rsp.stdout.should eq("Removed container 'my-added-container2'.\n")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "remove with invalid avl" do
      it "should report error" do
        rsp = cptr('containers:remove my-added-container2 -z blah')
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("containers:remove my-added-container2 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
