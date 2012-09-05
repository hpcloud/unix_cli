require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata remove command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = ServerTestHelper.create("image_meta_remove")

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

  context "images delete one" do
    it "should report success" do
      rsp = cptr("images:metadata:remove #{@image_id} aardvark")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      response.should include("aardvark")
      result = Images.new.get(@image_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("kangaroo=two")
      result.meta.to_s.should_not include("aardvark")
    end
  end

  context "images" do
    it "should report success" do
      rsp = cptr("images:metadata:remove #{@image_name} aardvark kangaroo")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      response.should include("aardvark")
      response.should include("kangaroo")
      result = Images.new.get(@image_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should_not include("kangaroo")
      result.meta.to_s.should_not include("aardvark")
    end
  end

  context "images with valid avl" do
    it "should report success" do
      rsp = cptr("images:metadata:remove -z az-1.region-a.geo-1 #{@image_id} aardvark kangaroo")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
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
      rsp = cptr("images:metadata:remove -z blah #{@image_id} aardvark kangaroo")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:metadata:remove -a bogus #{@image_id} something")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @img.destroy() unless @img.nil?
  end
end
