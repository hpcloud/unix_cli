# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Get command" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.put_container('get_container')
    @hp_svc.put_object('get_container', 'highly_unusual_file_name.txt', read_file('foo.txt'))
    @hp_svc.put_object('get_container', 'folder/highly_unusual_file_name.txt', read_file('foo.txt'))
    File.unlink('highly_unusual_file_name.txt') if File.exist?('highly_unusual_file_name.txt')
  end

  context "when object does not exist" do
    it "should exit with object not found" do
      rsp = cptr("get :get_container/nonexistant.txt")

      rsp.stderr.should eq("No files found matching source 'nonexistant.txt'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end
  
  context "when container does not exist" do
    it "should exit with container not found" do
      rsp = cptr("get :nonexistant_container/foo.txt")

      rsp.stderr.should eql("Cannot find container ':nonexistant_container'.\n")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "when syntax is not correct" do
    it "should exit with message about bad syntax" do
      rsp = cptr("get /foo/foo")

      rsp.stderr.should eq("Source object does not appear to be remote '/foo/foo'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when object and container exist and object is at container level" do
    it "should report success" do
      rsp = cptr("get :get_container/highly_unusual_file_name.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :get_container/highly_unusual_file_name.txt => .\n")
      rsp.exit_status.should be_exit(:success)
      File.exist?('highly_unusual_file_name.txt').should be_true
    end

    after(:all) do
      File.unlink('highly_unusual_file_name.txt')
    end
  end

  context "when object and container exist and object is in a nested folder" do
    it "should report success" do
      rsp = cptr("get :get_container/folder/highly_unusual_file_name.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied :get_container/folder/highly_unusual_file_name.txt => .\n")
      rsp.exit_status.should be_exit(:success)
      File.exist?('highly_unusual_file_name.txt').should be_true
    end

    after(:all) do
      File.unlink('highly_unusual_file_name.txt')
    end
  end

  context "when object and container exist and object is at container level" do
    it "should report success" do
      username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:grant :get_container rw #{username}")
      rsp.stderr.should eq("")
      rsp = cptr("location :get_container/highly_unusual_file_name.txt")
      rsp.stderr.should eq("")
      location=rsp.stdout.gsub("\n",'')

      rsp = cptr("get #{location} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied " + location + " => .\n")
      rsp.exit_status.should be_exit(:success)
      File.exist?('highly_unusual_file_name.txt').should be_true
    end

    after(:all) do
      File.unlink('highly_unusual_file_name.txt')
    end
  end

  context "when object and container exist but no grants" do
    it "should report failure" do
      username = AccountsHelper.get_username('secondary')
      rsp = cptr("acl:revoke :get_container rw #{username}")
      rsp.stderr.should eq("")
      rsp = cptr("location :get_container/highly_unusual_file_name.txt")
      rsp.stderr.should eq("")
      location=rsp.stdout.gsub("\n",'')

      rsp = cptr("get #{location} -a secondary")

      container=location.gsub("/highly_unusual_file_name.txt",'')
      rsp.stderr.should eq("Permission denied trying to access '#{container}/highly_unusual_file_name.txt'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:permission_denied)
    end
  end

  context "get with valid avl" do
    it "should report success" do
      rsp = cptr("get :get_container/highly_unusual_file_name.txt -z #{REGION}")

      rsp.stderr.should eql("")
      rsp.stdout.should eql("Copied :get_container/highly_unusual_file_name.txt => .\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "get with invalid avl" do
    it "should report error" do
      rsp = cptr('get :get_container/highly_unusual_file_name.txt -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("get :get_container/highly_unusual_file_name.txt -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    purge_container('get_container')
    File.unlink('highly_unusual_file_name.txt') if File.exist?('highly_unusual_file_name.txt')
  end
end
