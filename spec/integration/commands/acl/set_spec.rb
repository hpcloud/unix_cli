require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "Acl:set command" do
#
#  before(:all) do
#    @hp_svc = storage_connection
#    @hp_svc.put_container('acl_container')
#    @hp_svc.put_object('acl_container', 'foo.txt', read_file('foo.txt'))
#  end
#
#  context "when resource is not correct" do
#    it "should exit with message about not supported resource" do
#      response = capture(:stderr){ HP::Scalene::CLI.start(['acl:set', '/foo/foo', 'private']) }
#      response.should eql("Setting ACLs is only supported for containers and objects.\n")
#    end
#  end
#
#  context "when acl string is not correct" do
#    it "should exit with message about bad acl" do
#      response = capture(:stderr){ HP::Scalene::CLI.start(['acl:set', ':foo_container', 'blah-acl']) }
#      response.should eql("Your ACL 'blah-acl' is invalid.\nValid options are: private, public-read, public-read-write, authenticated-read, authenticated-read-write, container-owner-read, container-owner-full-control, log-delivery-write.\n")
#    end
#  end
#
#  context "when setting the ACL for a container" do
#    it "should report success" do
#      response = capture(:stdout){ HP::Scalene::CLI.start(['acl:set', ':acl_container', 'authenticated-read']) }
#      response.should eql("ACL for :acl_container updated to authenticated-read.\n")
#    end
#  end
#
#  context "when setting the ACL for an object" do
#    it "should report success" do
#      response = capture(:stdout){ HP::Scalene::CLI.start(['acl:set', ':acl_container/foo.txt', 'authenticated-read']) }
#      response.should eql("ACL for :acl_container/foo.txt updated to authenticated-read.\n")
#    end
#  end
#
#  after(:all) do
#    purge_container('acl_container')
#  end
  
end
