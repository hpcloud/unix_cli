require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'hpcloud/server_helper'

describe "Servers command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.meta.set_metadata('luke=skywalker,han=solo')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = @srv.id
    @server_name = @srv.name
  end

  describe "with avl settings from config" do
    context "servers" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata #{@server_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("luke")
        response.should include("skywalker")
        response.should include("han")
        response.should include("solo")
      end
    end

    context "servers" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata #{@server_name}").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("luke")
        response.should include("skywalker")
        response.should include("han")
        response.should include("solo")
      end
    end

    context "servers:metadata:list" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata:list #{@server_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
  end
  describe "with avl settings passed in" do
    context "servers with valid avl" do
      it "should report success" do
        response, exit_status = run_command("servers:metadata:list -z az-1.region-a.geo-1 #{@server_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
    context "servers with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:metadata -z blah #{@server_id}").stderr_and_exit_status
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
