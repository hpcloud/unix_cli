#require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
#require 'hpcloud/server_helper'
#
#describe "Servers metadata add command" do
#  before(:all) do
#    @flavor_id = OS_COMPUTE_BASE_FLAVOR_ID
#    @image_id = OS_COMPUTE_BASE_IMAGE_ID
#
#    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
#    @srv.name = resource_name("meta_srv")
#    @srv.flavor = @flavor_id
#    @srv.image = @image_id
#    @srv.meta.set_metadata('luke=skywalker,han=solo')
#    @srv.save.should be_true
#    @srv.fog.wait_for { ready? }
#
#    @server_id = "#{@srv.id}"
#    @server_name = @srv.name
#  end
#
#  def still_contains_original(metastr)
#    metastr.should include("luke=skywalker")
#    metastr.should include("han=solo")
#  end
#
#  describe "with avl settings from config" do
#    context "servers" do
#      it "should report success" do
#        response, exit_status = run_command("servers:metadata:add #{@server_id} id1=one,id2=2").stdout_and_exit_status
#
#        exit_status.should be_exit(:success)
#        result = Servers.new.get(@server_id)
#        still_contains_original(result.meta.to_s)
#        result.meta.to_s.should include("id1=one")
#        result.meta.to_s.should include("id2=2")
#      end
#    end
#
#    context "servers" do
#      it "should report success" do
#        response, exit_status = run_command("servers:metadata:add #{@server_name} name1=1,name2=2").stdout_and_exit_status
#
#        exit_status.should be_exit(:success)
#        result = Servers.new.get(@server_id)
#        still_contains_original(result.meta.to_s)
#        result.meta.to_s.should include("name1=1")
#        result.meta.to_s.should include("name2=2")
#      end
#    end
#
#  end
#
#  describe "with avl settings passed in" do
#    context "servers with valid avl" do
#      it "should report success" do
#        response, exit_status = run_command("servers:metadata:add -z az-1.region-a.geo-1 #{@server_id} avl1=1,avl2=2").stdout_and_exit_status
#
#        exit_status.should be_exit(:success)
#        result = Servers.new.get(@server_id)
#        still_contains_original(result.meta.to_s)
#        result.meta.to_s.should include("avl1=1")
#        result.meta.to_s.should include("avl2=2")
#      end
#    end
#    context "servers with invalid avl" do
#      it "should report error" do
#        response, exit_status = run_command("servers:metadata:add -z blah #{@server_id} blah1=1,blah2=2").stderr_and_exit_status
#        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
#        exit_status.should be_exit(:general_error)
#      end
#      after(:all) { HP::Cloud::Connection.instance.set_options({}) }
#    end
#  end
#
#  after(:all) do
#    @srv.destroy() unless @srv.nil?
#  end
#end