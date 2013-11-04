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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:add" do
  context "when creating" do
    it "should show success message" do
      @lb_name = resource_name("cliadd1")
      cptr("lb:remove #{@lb_name}")

      rsp = cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.2.2.2:80")

      rsp.stderr.should eq("")
      @new_lb_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created load balancer '#{@lb_name}' with id '#{@new_lb_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb -c name,algorithm,protocol,port -d X #{@lb_name}")
      rsp.stdout.should eq("#{@lb_name}XROUND_ROBINXHTTPX80\n")
    end

    after(:each) do
      cptr("lb:remove #{@lb_name}")
    end
  end

  context "when creating lb with a name that already exists" do
    it "should fail" do
      @lb_name = "cliadd2"
      cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.2.2.2:80")

      rsp = cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.2.2.2:80")

      rsp.stderr.should eq("A load balancer with the name '#{@lb_name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end
end
