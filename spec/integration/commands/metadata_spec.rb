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

describe "metadata" do
  context "metadata" do
    it "should report success" do
      tainer = ":objmeteatst"
      cptr("remove -f #{tainer}")
      cptr("containers:add #{tainer}")
      cptr("copy spec/fixtures/files/Matryoshka/Putin/Medvedev.txt #{tainer}")

      rsp = cptr("metadata #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("X-Container-Bytes-Used 16\nX-Container-Object-Count 1\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata:set #{tainer}/Medvedev.txt X-Object-Meta-Foo valuu")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Object-Meta-Foo' with value 'valuu' was set on object ':objmeteatst/Medvedev.txt'.\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata:set #{tainer} X-Container-Meta-Foo valtoo")
      rsp.stderr.should eq("")
      rsp.stdout.should eq("The attribute 'X-Container-Meta-Foo' with value 'valtoo' was set on object ':objmeteatst'.\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}/Medvedev.txt")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Content-Type text/plain\nX-Object-Meta-Foo valuu\n")
      rsp.exit_status.should be_exit(:success)

      rsp = cptr("metadata #{tainer}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("X-Container-Bytes-Used 16\nX-Container-Meta-Foo valtoo\nX-Container-Object-Count 1\n")
      rsp.exit_status.should be_exit(:success)
    end
  end
end
