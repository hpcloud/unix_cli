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
  end

  after(:all) do
     purge_container('acl_container')
  end
end
