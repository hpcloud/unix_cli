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

require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe "dns:records:add command" do
  before(:each) do
    @dns1 = DnsTestHelper.create("clitest1.com.")
  end

  context "when creating dns with name description" do
    it "should show success message" do
      rsp = cptr("dns:records:add #{@dns1.name} www.clitest1.com. A 10.0.0.1")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns record 'www.clitest1.com.' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("dns:records -c name,type,data -d X #{@dns1.name}")
      rsp.stdout.should match("www.clitest1.com.XAX10.0.0.1\n")
    end

    after(:each) do
      cptr("dns:record:remove #{@dns1.name} www.clitest1.com.")
    end
  end
end
