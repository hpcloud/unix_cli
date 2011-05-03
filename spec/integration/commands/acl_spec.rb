require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Acl commands" do

  before(:all) do
    @kvs = storage_connection
    @kvs.put_bucket('acl_bucket')
    @kvs.put_object('acl_bucket', 'foo.txt', read_file('foo.txt'))
  end

  context "Acl:set command (setting acls)" do
    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['acl:set', '/foo/foo']) }
        response.should eql("\"acl:set\" was called incorrectly. Call as \"rspec acl:set <resource> <canned-acl>\".\n")
      end
    end
    context "when resource is not correct" do
      it "should exit with message about not supported resource" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['acl:set', '/foo/foo', 'private']) }
        response.should eql("Setting ACLs is only supported for buckets and objects\n")
      end
    end
    context "when acl string is not correct" do
      it "should exit with message about bad acl" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['acl:set', ':foo_bucket', 'blah-acl']) }
        response.should eql("Your ACL 'blah-acl' is invalid.\nValid options are: private, public-read, public-read-write, authenticated-read, authenticated-read-write, bucket-owner-read, bucket-owner-full-control, log-delivery-write.\n")
      end
    end
    context "when setting the ACL for a bucket" do
      it "should report success" do
        response = capture(:stdout){ HP::Scalene::CLI.start(['acl:set', ':acl_bucket', 'authenticated-read']) }
        response.should eql("ACL for :acl_bucket updated to authenticated-read\n")
      end
    end
    context "when setting the ACL for an object" do
      it "should report success" do
        response = capture(:stdout){ HP::Scalene::CLI.start(['acl:set', ':acl_bucket/foo.txt', 'authenticated-read']) }
        response.should eql("ACL for :acl_bucket/foo.txt updated to authenticated-read\n")
      end
    end
  end
  context "Acl command (viewing acls)" do
    context "when syntax is not correct" do
      it "should exit with message about bad syntax" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['acl']) }
        response.should eql("\"acl\" was called incorrectly. Call as \"rspec acl <resource>\".\n")
      end
    end
    context "when resource is not correct" do
      it "should exit with message about not supported resource" do
        response = capture(:stderr){ HP::Scalene::CLI.start(['acl', '/foo/foo']) }
        response.should eql("ACL viewing is only supported for buckets and objects\n")
      end
    end
    context "when viewing the ACL for a bucket" do
      before (:all) do
        @kvs.put_bucket_acl('acl_bucket', 'authenticated-read-write')
        @response = capture(:stdout){ HP::Scalene::CLI.start(['acl', ':acl_bucket']) }
      end
      it "should have FULL_CONTROL permissions" do
        @response.should include("FULL_CONTROL")
      end
      it "should have READ permissions for AuthenticatedUsers group" do
        @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  READ")
      end
      it "should have WRITE permissions for AuthenticatedUsers group" do
        @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  WRITE")
      end
    end
    context "when viewing the ACL for an object" do
      before (:all) do
        @kvs.put_object_acl('acl_bucket', 'foo.txt','authenticated-read-write')
        @response = capture(:stdout){ HP::Scalene::CLI.start(['acl', ':acl_bucket/foo.txt']) }
      end
      it "should have FULL_CONTROL permissions" do
        @response.should include("FULL_CONTROL")
      end
      it "should have READ permissions for AuthenticatedUsers group" do
        @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  READ")
      end
      it "should have WRITE permissions for AuthenticatedUsers group" do
        @response.should include("http://acs.amazonaws.com/groups/global/AuthenticatedUsers  WRITE")
      end
    end
  end

  after(:all) do
     purge_bucket('acl_bucket')
   end
end