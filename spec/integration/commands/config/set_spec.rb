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
require 'yaml'

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  context "set good" do
    it "should set value" do
      rsp = cptr("config:set ssl_ca_path=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set ssl_ca_path=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:ssl_ca_path).should eql("blah2")
    end
  end

  context "set bogus" do
    it "should set value" do
      rsp = cptr("config:set bogus=blah2")
      rsp.stderr.should eql("Unknown configuration key value 'bogus'\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "set empty configuration value" do
    it "should set value" do
      rsp = cptr("config:set ssl_ca_file=")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set ssl_ca_file=\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:ssl_ca_file).should be_nil
    end
  end

  context "set using add alias" do
    it "should set value" do
      rsp = cptr("config:add read_timeout=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set read_timeout=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:read_timeout).should eql("blah2")
    end
  end

  context "set using update alias" do
    it "should set value" do
      rsp = cptr("config:update write_timeout=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set write_timeout=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:write_timeout).should eql("blah2")
    end
  end

  context "set everything" do
    it "should set value" do
      rsp = cptr("config:update default_auth_uri=1 connect_timeout=6 read_timeout=7 write_timeout=8 ssl_verify_peer=9 ssl_ca_path=10 ssl_ca_file=11")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set default_auth_uri=1 connect_timeout=6 read_timeout=7 write_timeout=8 ssl_verify_peer=9 ssl_ca_path=10 ssl_ca_file=11\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:default_auth_uri).should eq("1")
      ConfigHelper.value(:connect_timeout).should eq("6")
      ConfigHelper.value(:read_timeout).should eq("7")
      ConfigHelper.value(:write_timeout).should eq("8")
      ConfigHelper.value(:ssl_verify_peer).should eq(true)
      ConfigHelper.value(:ssl_ca_path).should eq("10")
      ConfigHelper.value(:ssl_ca_file).should eq("11")
    end
  end
  after(:all) {reset_all()}
end
