require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata remove command" do
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
    @img.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
    @img.save.should be_true
    @img = Images.new.get(@img.id)

    @image_id = "#{@img.id}"
    @image_name = @img.name
  end

  before(:each) do
    @img = Images.new.get(@image_id)
    @img.meta.set_metadata('aardvark=three,luke=skywalker,han=solo,kangaroo=two')
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  describe "with avl settings from config" do
    context "images delete one" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:remove #{@image_id} aardvark").stdout_and_exit_status

        exit_status.should be_exit(:success)
        response.should include("aardvark")
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should include("kangaroo=two")
        result.meta.to_s.should_not include("aardvark")
      end
    end

    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:remove #{@image_name} aardvark kangaroo").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("aardvark")
        response.should include("kangaroo")
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end

  end

  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:remove -z az-1.region-a.geo-1 #{@image_id} aardvark kangaroo").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("Removed metadata 'aardvark' from image")
        response.should include("Removed metadata 'kangaroo' from image")
        result = Images.new.get(@image_id)
        still_contains_original(result.meta.to_s)
        result.meta.to_s.should_not include("kangaroo")
        result.meta.to_s.should_not include("aardvark")
      end
    end

    context "images with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("images:metadata:remove -z blah #{@image_id} aardvark kangaroo").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.clear_options() }
    end
  end

  after(:all) do
    @img.destroy() unless @img.nil?
  end
end
