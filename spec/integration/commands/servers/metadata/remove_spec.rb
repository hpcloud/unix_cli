require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/server_helper'

describe "Servers metadata remove command" do
  before(:all) do
    @flavor_id = OS_COMPUTE_BASE_FLAVOR_ID
    @image_id = OS_COMPUTE_BASE_IMAGE_ID

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = "#{@srv.id}"
    @server_name = @srv.name
  end

  before(:each) do
    @srv = Servers.new.get(@server_id)
    @srv.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  describe "with avl settings from config" do
    context "servers delete one" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata:remove #{@server_id} aardvark").stdout_and_exit_status

        exit_status.should be_exit(:success)
        response.should include("aardvark")
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("kangaroo=two")
        result.meta.to_s.should_not include("aardvark")
      end
    end

    context "servers" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata:remove #{@server_name} aardvark kangaroo").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("aardvark")
        response.should include("kangaroo")
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end

  end

  describe "with avl settings passed in" do
    context "servers with valid avl" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata:remove -z az-1.region-a.geo-1 #{@server_id} aardvark kangaroo").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("Removed metadata 'aardvark' from server")
        response.should include("Removed metadata 'kangaroo' from server")
        result = Servers.new.get(@server_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end
    context "servers with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:metadata:remove -z blah #{@server_id} aardvark kangaroo").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.set_options({}) }
    end
  end

  after(:all) do
    @srv.destroy() unless @srv.nil?
  end
end
