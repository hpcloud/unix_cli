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

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  def default_config(contents)
    contents.should include("default_auth_uri: https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/")
    contents.should include("connect_timeout: 30")
    contents.should include("read_timeout: 240")
    contents.should include("write_timeout: 240")
    contents.should include("ssl_verify_peer: true")
  end

  context "config" do
    it "should report success" do
      rsp = cptr('config')
      rsp.stderr.should eq("")
      default_config(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end
  context "config:list" do
    it "should report success" do
      rsp = cptr('config:list')
      rsp.stderr.should eq("")
      default_config(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end
  after(:all) {reset_all()}
end
