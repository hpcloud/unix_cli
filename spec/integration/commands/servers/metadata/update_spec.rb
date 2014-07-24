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
require 'hpcloud/server_helper'

describe "Servers metadata update command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.set_network('cli_test_network1')
    @srv.meta.set_metadata('luke=skywalker,han=solo')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = "#{@srv.id}"
    @server_name = @srv.name
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata:update #{@server_id} luke=l000001,han=h000001")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_id}' set metadata 'luke=l000001,han=h000001'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      result.meta.to_s.should include("luke=l000001")
      result.meta.to_s.should include("han=h000001")
    end
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata:update #{@server_name} luke=l000002,han=h000002")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_name}' set metadata 'luke=l000002,han=h000002'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      result.meta.to_s.should include("luke=l000002")
      result.meta.to_s.should include("han=h000002")
    end
  end

  context "servers with valid avl" do
    it "should report success" do
      rsp = cptr("servers:metadata:update -z #{REGION} #{@server_id} luke=l000003,han=h000003")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_id}' set metadata 'luke=l000003,han=h000003'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      result.meta.to_s.should include("luke=l000003")
      result.meta.to_s.should include("han=h000003")
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:metadata:update -z blah #{@server_id} blah1=1,blah2=2")
      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:metadata:update #{@server_id} blah1=1,blah2=2 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @srv.destroy() unless @srv.nil?
  end
end
