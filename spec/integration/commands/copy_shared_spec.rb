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

describe "Copy shared resources" do
  before(:all) do
    rsp = cptr("containers:add :copytainer")
    rsp = cptr("containers:add :readtainer")
    username = AccountsHelper.get_username('secondary')
    rsp = cptr("acl:grant :copytainer rw #{username}")
    rsp.stderr.should eq("")
    rsp = cptr("acl:grant :readtainer r #{username}")
    rsp.stderr.should eq("")
    rsp = cptr("location :copytainer")
    rsp.stderr.should eq("")
    @container = rsp.stdout.gsub("\n",'')
    rsp = cptr("location :readtainer")
    rsp.stderr.should eq("")
    @readtainer = rsp.stdout.gsub("\n",'')
    @local = "spec/tmp/shared/"
    FileUtils.rm_rf(@local)
    FileUtils.mkdir_p(@local)

    #
    # Use this test to populate for the other tests
    #
    rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/ #{@container}/ -a secondary")
    rsp.stderr.should eq("")
    rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/ => #{@container}/\n")
    rsp.exit_status.should be_exit(:success)
  end
  
  context "when container does not exist" do
    it "should exit with container not found" do
      missing = "#{@container}missing"
      rsp = cptr("copy #{missing} #{@local} -a secondary")

      rsp.stderr.should eq("Permission denied trying to access '#{missing}'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:permission_denied)
    end
  end

  context "when file and container exist" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/Boris.txt #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/Boris.txt => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when regex" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/ #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/ => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when regex" do
    it "should copy" do
      rsp = cptr("copy #{@container}/Yeltsin/Gorbachev/.* #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied #{@container}/Yeltsin/Gorbachev/.* => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when local file" do
    it "should copy" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt #{@container}/ -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Copied spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt => #{@container}/\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when container to container" do
    it "not allowed for now" do
      rsp = cptr("copy #{@container}/Yeltsin/Gorbachev/Andropov.txt #{@container}/spare/ -a secondary")

      rsp.stderr.should eq("<html><h1>Forbidden</h1><p>Access was denied to this resource.</p></html>\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
  
  context "move to local" do
    it "should work" do
      rsp = cptr("move #{@container}/Yeltsin/Gorbachev/Andropov.txt #{@local} -a secondary")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Moved #{@container}/Yeltsin/Gorbachev/Andropov.txt => #{@local}\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
  
  context "when read only" do
    it "should fail" do
      rsp = cptr("copy spec/fixtures/files/Matryoshka/Putin/Yeltsin/Gorbachev/Andropov.txt #{@readtainer}/ -a secondary")

      rsp.stderr.should eq("<html><h1>Forbidden</h1><p>Access was denied to this resource.</p></html>\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
  
  after(:all) do
#    cptr("remove -f :copytainer")
#    cptr("remove -f :readtainer")
  end
end
