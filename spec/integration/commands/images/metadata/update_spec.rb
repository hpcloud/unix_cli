require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata update command" do
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

    @img = HP::Cloud::ImageHelper.new()
    @img.name = resource_name("meta_img")
    @img.set_server("#{@srv.id}")
    @img.meta.set_metadata('darth=vader,count=dooku')
    @img.save.should be_true
    @img = Images.new.get(@img.id)

    @image_id = "#{@img.id}"
    @image_name = @img.name
  end

  describe "with avl settings from config" do
    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:update #{@image_id} luke=l000001,han=h000001").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        result.meta.to_s.should include("luke=l000001")
        result.meta.to_s.should include("han=h000001")
      end
    end

    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:update #{@image_name} luke=l000002,han=h000002").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        result.meta.to_s.should include("luke=l000002")
        result.meta.to_s.should include("han=h000002")
      end
    end

  end

  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:update -z az-1.region-a.geo-1 #{@image_id} luke=l000003,han=h000003").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        result.meta.to_s.should include("luke=l000003")
        result.meta.to_s.should include("han=h000003")
      end
    end
    context "images with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("images:metadata:update -z blah #{@image_id} blah1=1,blah2=2").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:metadata:update -a bogus #{@image_id} blah1=1,blah2=2")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @srv.destroy() unless @srv.nil?
    @img.destroy() unless @img.nil?
  end
end
