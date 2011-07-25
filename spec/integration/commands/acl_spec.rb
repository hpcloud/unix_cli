require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Acl command (viewing acls)" do
  
#  before(:all) do
#    @hp_svc = storage_connection
#    @hp_svc.put_container('acl_container')
#    @hp_svc.put_object('acl_container', 'foo.txt', read_file('foo.txt'))
#  end
#
#  context "when resource is not correct" do
#    it "should exit with message about not supported resource" do
#      message = run_command('acl /foo/foo').stderr
#      message.should eql("ACL viewing is only supported for containers and objects\n")
#    end
#  end
#
#  context "when viewing the ACL for a container" do
#    before (:all) do
#      #### @hp_svc.put_container_acl('acl_container', 'authenticated-read-write')
#      @response = run_command('acl :acl_container')
#    end
#    it "should have FULL_CONTROL permissions" do
#      @response.should include("FULL_CONTROL")
#    end
#    it "should have READ permissions for AuthenticatedUsers group" do
#      @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  READ")
#    end
#    it "should have WRITE permissions for AuthenticatedUsers group" do
#      @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  WRITE")
#    end
#  end
#
#  context "when viewing the ACL for an object" do
#    before (:all) do
#      @hp_svc.put_object_acl('acl_container', 'foo.txt','authenticated-read-write')
#      @response = run_command('acl :acl_container/foo.txt')
#    end
#    it "should have FULL_CONTROL permissions" do
#      @response.should include("FULL_CONTROL")
#    end
#    it "should have READ permissions for AuthenticatedUsers group" do
#      @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  READ")
#    end
#    it "should have WRITE permissions for AuthenticatedUsers group" do
#      @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  WRITE")
#    end
#  end
#
#  after(:all) do
#     purge_container('acl_container')
#  end
end
