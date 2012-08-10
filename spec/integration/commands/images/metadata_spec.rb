require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images command" do
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

    @image_id = @img.id
    @image_name = @img.name
  end

  describe "with avl settings from config" do
    context "images" do
      it "should report success" do
        response, exit_status = run_command("images:metadata #{@image_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("count")
        response.should include("dooku")
        response.should include("darth")
        response.should include("vader")
      end
    end

    context "images with name" do
      it "should report success" do
        response, exit_status = run_command("images:metadata #{@image_name}").stdout_and_exit_status
        exit_status.should be_exit(:success)
        response.should include("count")
        response.should include("dooku")
        response.should include("darth")
        response.should include("vader")
      end
    end

    context "images:metadata:list" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:list #{@image_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end
  end
  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        response, exit_status = run_command("images:metadata:list -z az-1.region-a.geo-1 #{@image_id}").stdout_and_exit_status
        exit_status.should be_exit(:success)
      end
    end

    context "images with invalid avl" do
      it "should report error" do
        response, exit_status = run_command('images:metadata -z blah #{@image_id}"').stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.set_options({}) }
    end
  end

  after(:all) do
    @img.destroy() unless @img.nil?
    @srv.destroy() unless @srv.nil?
  end
end
