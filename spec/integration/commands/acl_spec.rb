require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Acl command (viewing acls)" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.directories.create(:key => 'acl_container')
    @hp_svc.directories.get('acl_container').files.create(:key => "foo.txt", :body => read_file('foo.txt'))
  end

  context "when resource is not correct" do
    it "should exit with message about not supported resource" do
      message = run_command('acl /foo/foo').stderr
      message.should eql("ACL viewing is only supported for containers and objects. See `help acl`.\n")
    end
  end

  context "when viewing the ACL for a private" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = false
      @dir.save
    end
    context "container" do
      before(:all) do
        @response, @exit = run_command('acl :acl_container').stdout_and_exit_status
      end
      it "should have 'private' permissions" do
        @response.should eql("private\n")
      end
      its_exit_status_should_be(:success)
    end
    context "object" do
      before(:all) do
        @response, @exit = run_command('acl :acl_container/foo.txt').stdout_and_exit_status
      end
      it "should have 'private' permissions" do
        @response.should eql("private\n")
      end
      its_exit_status_should_be(:success)
    end
    describe "with avl settings passed in" do
      context "acl for container with valid avl" do
        it "should report success" do
          response, exit_status = run_command('acl :acl_container -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "acl for object with valid avl" do
        it "should report success" do
          response, exit_status = run_command('acl :acl_container/foo.txt -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "acl for container with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('acl :acl_container -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
      context "acl for object with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('acl :acl_container/foo.txt -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
    end
  end

  context "when viewing the ACL for a public" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = true
      @dir.save
    end
    context "container" do
      before(:all) do
        @response, @exit = run_command('acl :acl_container').stdout_and_exit_status
      end
      it "should have 'public' permissions" do
        @response.should eql("public-read\n")
      end
      its_exit_status_should_be(:success)
    end
    context "object" do
      before(:all) do
        @response, @exit = run_command('acl :acl_container/foo.txt').stdout_and_exit_status
      end
      it "should have 'public' permissions" do
        @response.should eql("public-read\n")
      end
      its_exit_status_should_be(:success)
    end
    describe "with avl settings passed in" do
      context "acl for container with valid avl" do
        it "should report success" do
          response, exit_status = run_command('acl :acl_container -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "acl for object with valid avl" do
        it "should report success" do
          response, exit_status = run_command('acl :acl_container/foo.txt -z region-a.geo-1').stdout_and_exit_status
          exit_status.should be_exit(:success)
        end
      end
      context "acl for container with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('acl :acl_container -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
      context "acl for object with invalid avl" do
        it "should report error" do
          response, exit_status = run_command('acl :acl_container/foo.txt -z blah').stderr_and_exit_status
          response.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
          exit_status.should be_exit(:general_error)
        end
        after(:all) { Connection.instance.set_options({}) }
      end
    end
  end

  after(:all) do
     purge_container('acl_container')
  end
end
