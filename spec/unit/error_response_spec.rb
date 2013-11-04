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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "ErrorResponse" do
  before(:each) do
    @response = double("response")
    @error = double("error")
  end

  context "when json" do
    it "gets json" do
      @error.stub("respond_to?").and_return(true)
      @error.stub(:response).and_return(@response)
      @response.stub(:body).and_return('{"badRequest": {"details": "Permission denied.", "message": "Unauthorized", "code": 403}}')

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Unauthorized: Permission denied.")
    end
  end

  context "when response body" do
    it "gets message body" do
      @error.stub("respond_to?").and_return(true)
      @error.stub(:response).and_return(@response)
      @response.stub(:body).and_return("403 Permission Denied\n\nBlah blah")

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Permission Denied\n\nBlah blah")
    end
  end

  context "when no response body" do
    it "gets message" do
      @error.stub("respond_to?").and_return(false)
      @error.stub(:message).and_return("403 Permission denied")

      msg = HP::Cloud::ErrorResponse.new(@error)

      msg.error_string.should eq("403 Permission denied")
    end
  end
end
