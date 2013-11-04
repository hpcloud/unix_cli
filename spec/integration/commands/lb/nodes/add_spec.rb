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

describe "lb:nodes:add" do
  context "when creating" do
    it "should show success message" do
      @lb_name = "cli_test_lb8"
      cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.2.2.2:80")
      cptr("lb:nodes:remove #{@lb_name} 10.2.2.3 81")

      rsp = cptr("lb:nodes:add #{@lb_name} 10.2.2.3 81")

      rsp.stderr.should eq("")
      #@new_node_id = rsp.stdout.scan(/'([^']+)/)[2][0] #LBAAS-178
      @new_node_id = ''
      rsp.stdout.should eq("Created node '10.2.2.3:81' with id '#{@new_node_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      rsp = cptr("lb:nodes #{@lb_name} -c address,port -d X")
      rsp.stdout.should include("10.2.2.3X81\n")
    end

    after(:each) do
      cptr("lb:nodes:remove #{@lb_name} 10.2.2.3 81")
    end
  end
end
