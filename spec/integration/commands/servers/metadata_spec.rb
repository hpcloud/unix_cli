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
    @srv.set_network('cli_test_network1')
    @srv.meta.set_metadata('luke=skywalker,han=solo')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = @srv.id
    @server_name = @srv.name
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata #{@server_id}")

      rsp.stderr.should eq("")
      rsp.stdout.should include("luke")
      rsp.stdout.should include("skywalker")
      rsp.stdout.should include("han")
      rsp.stdout.should include("solo")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers" do
    it "should report success" do
      rsp = cptr("servers:metadata #{@server_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should include("luke")
      rsp.stdout.should include("skywalker")
      rsp.stdout.should include("han")
      rsp.stdout.should include("solo")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers:metadata:list" do
    it "should report success" do
      rsp = cptr("servers:metadata:list #{@server_id}")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with valid avl" do
    it "should report success" do
      rsp = cptr("servers:metadata:list -z region-b.geo-1 #{@server_id}")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:metadata -z blah #{@server_id}")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:metadata #{@server_id} -a bogus")

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
