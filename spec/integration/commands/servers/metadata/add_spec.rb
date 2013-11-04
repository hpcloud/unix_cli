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

describe "Servers metadata add command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.meta.set_metadata('luke=skywalker,han=solo')
    @srv.set_network('cli_test_network1')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = "#{@srv.id}"
    @server_name = @srv.name
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata:add #{@server_id} id1=one,id2=2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_id}' set metadata 'id1=one,id2=2'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("id1=one")
      result.meta.to_s.should include("id2=2")
    end
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata:add #{@server_name} name1=1,name2=2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_name}' set metadata 'name1=1,name2=2'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("name1=1")
      result.meta.to_s.should include("name2=2")
    end
  end

  context "servers with valid avl" do
    it "should report success" do
      rsp = cptr("servers:metadata:add -z region-b.geo-1 #{@server_id} avl1=1,avl2=2")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Server '#{@server_id}' set metadata 'avl1=1,avl2=2'.\n")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("avl1=1")
      result.meta.to_s.should include("avl2=2")
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:metadata:add -z blah #{@server_id} blah1=1,blah2=2")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:metadata:add #{@server_id} blah1=1,blah2=2 -a bogus")

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
