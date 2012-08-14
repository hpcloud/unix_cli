require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata add command" do
  before(:all) do
    @flavor_id = OS_COMPUTE_BASE_FLAVOR_ID
    @image_id = OS_COMPUTE_BASE_IMAGE_ID

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

  def still_contains_original(metastr)
    metastr.should include("darth=vader")
    metastr.should include("count=dooku")
  end

  describe "with avl settings from config" do
    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:add #{@image_id} id1=one,id2=2").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("id1=one")
        result.meta.to_s.should include("id2=2")
      end
    end

    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:add #{@image_name} name1=1,name2=2").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("name1=1")
        result.meta.to_s.should include("name2=2")
      end
    end

    context "bad image" do
      it "should report failure" do
        rsp = cptr("images:metadata:add bogus name1=1,name2=2")

        rsp.stderr.should eq("Cannot find a image matching 'bogus'.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:not_found)
      end
    end

  end

  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:add -z az-1.region-a.geo-1 #{@image_id} avl1=1,avl2=2").stdout_and_exit_status

        exit_status.should be_exit(:success)
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("avl1=1")
        result.meta.to_s.should include("avl2=2")
      end
    end
    context "images with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("images:metadata:add -z blah #{@image_id} blah1=1,blah2=2").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.set_options({}) }
    end
  end

  after(:all) do
    @srv.destroy() unless @srv.nil?
    @img.destroy() unless @img.nil?
  end
end
