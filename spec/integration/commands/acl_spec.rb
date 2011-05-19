require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Acl command (viewing acls)" do
  
  before(:all) do
    @kvs = storage_connection
    @kvs.put_bucket('acl_bucket')
    @kvs.put_object('acl_bucket', 'foo.txt', read_file('foo.txt'))
  end
  
  context "when resource is not correct" do
    it "should exit with message about not supported resource" do
      message = run_command('acl /foo/foo').stderr
      message.should eql("ACL viewing is only supported for buckets and objects\n")
    end
  end
  
  context "when viewing the ACL for a bucket" do
    before (:all) do
      @kvs.put_bucket_acl('acl_bucket', 'authenticated-read-write')
      @stdout = run_command('acl :acl_bucket').stdout
    end
    it "should have FULL_CONTROL permissions" do
      @stdout.should include("FULL_CONTROL")
    end
    it "should have READ permissions for AuthenticatedUsers group" do
      @stdout.should match("http://acs.amazonaws.com/groups/global/AuthenticatedUsers.*READ")
    end
    it "should have WRITE permissions for AuthenticatedUsers group" do
      @stdout.should match("http://acs.amazonaws.com/groups/global/AuthenticatedUsers.*WRITE")
    end
  end
  
  context "when viewing the ACL for an object" do
    before (:all) do
      @kvs.put_object_acl('acl_bucket', 'foo.txt','authenticated-read-write')
      @stdout = run_command('acl :acl_bucket/foo.txt').stdout
    end
    it "should have FULL_CONTROL permissions" do
      @stdout.should include("FULL_CONTROL")
    end
    it "should have READ permissions for AuthenticatedUsers group" do
      @stdout.should match("http://acs.amazonaws.com/groups/global/AuthenticatedUsers.*READ")
    end
    it "should have WRITE permissions for AuthenticatedUsers group" do
      @stdout.should match("http://acs.amazonaws.com/groups/global/AuthenticatedUsers.*WRITE")
    end
  end
  
  after(:all) do
     purge_bucket('acl_bucket')
  end
end
