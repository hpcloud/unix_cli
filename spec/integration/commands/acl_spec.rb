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

describe "Acl command (viewing acls)" do
  
  before(:all) do
    @hp_svc = storage_connection
    @hp_svc.directories.create(:key => 'acl_container')
    @hp_svc.directories.get('acl_container').files.create(:key => "foo.txt", :body => read_file('foo.txt'))
  end

  context "when resource is not correct" do
    it "should exit with message about not supported resource" do
      rsp = cptr('acl /foo/foo')

      rsp.stderr.should eq("Not supported on local object '/foo/foo'.\n")
      rsp.stdout.should eq("There are no resources that match the provided arguments\n")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  describe "when viewing the ACL for a private" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = false
      @dir.save
    end

    context "container" do
      it "should have 'private' permissions" do
        rsp = cptr('acl -d , :acl_container')

        rsp.stderr.should eq("")
        rsp.stdout.should match("no,,,http://.*acl_container")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "object" do
      it "should have 'private' permissions" do
        rsp = cptr('acl -d , :acl_container/foo.txt')

        rsp.stderr.should eq("")
        rsp.stdout.should match("no,,,http.*acl_container/foo.txt")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with valid avl" do
      it "should report success" do
        rsp = cptr("acl -d , :acl_container -z #{REGION}")

        rsp.stderr.should eq("")
        rsp.stdout.should match("no,,,http.*acl_container")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for object with valid avl" do
      it "should report success" do
        rsp = cptr("acl -d , :acl_container/foo.txt -z #{REGION}")

        rsp.stderr.should eq("")
        rsp.stdout.should match("no,,,http.*acl_container/foo.txt")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    context "acl for object with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container/foo.txt -z blah')
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eql("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  describe "when viewing the ACL for a public" do
    before(:all) do
      @dir = @hp_svc.directories.get('acl_container')
      @dir.public = true
      @dir.save
    end

    context "container" do
      it "should have 'public' permissions" do
        rsp = cptr('acl -d , :acl_container')

        rsp.stderr.should eq("")
        rsp.stdout.should match("yes,,,http.*acl_container")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "object" do
      it "should have 'public' permissions" do
        rsp = cptr('acl -d , :acl_container/foo.txt')

        rsp.stderr.should eq("")
        rsp.stdout.should match("yes,,,http.*acl_container/foo.txt")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with valid avl" do
      it "should report success" do
        rsp = cptr("acl -d , :acl_container -z #{REGION}")

        rsp.stderr.should eq("")
        rsp.stdout.should match("yes,,,http.*acl_container")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for object with valid avl" do
      it "should report success" do
        rsp = cptr("acl -d , :acl_container/foo.txt -z #{REGION}")

        rsp.stderr.should eq("")
        rsp.stdout.should match("yes,,,http.*acl_container")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "acl for container with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end

    context "acl for object with invalid avl" do
      it "should report error" do
        rsp = cptr('acl :acl_container/foo.txt -z blah')

        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Storage' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  describe "when viewing the ACL for a public" do
    before(:all) do
      @default_username = AccountsHelper.get_username()
      @username = AccountsHelper.get_username('secondary')
      cptr("acl:grant :acl_container r #{@default_username}")
      cptr("acl:grant :acl_container w #{@username}")
    end

    context "container" do
      it "should have 'public' permissions" do
        rsp = cptr("acl -d X :acl_container")

        rsp.stderr.should eq("")
        rsp.stdout.should match("noX#{@default_username}X#{@username}Xhttp.*/acl_container\n$")
        rsp.exit_status.should be_exit(:success)
      end
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("acl :acl_container/foo.txt -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    purge_container('acl_container')
  end
end
