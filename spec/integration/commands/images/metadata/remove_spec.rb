require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata remove command" do
  before(:all) do
    @srv = ServerTestHelper.create("cli_test_srv1")
    @img = ImageTestHelper.create("cli_test_img1", @srv)
  end

  before(:each) do
    cptr("images:metadata:update #{@img.id} aardvark=three,luke=skywalker,han=solo,kangaroo=two")
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  context "images delete one" do
    it "should report success" do
      rsp = cptr("images:metadata:remove #{@img.id} aardvark")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      rsp.stdout.should include("aardvark")
      result = Images.new.get("#{@img.id}")
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("kangaroo=two")
      result.meta.to_s.should_not include("aardvark")
    end
  end

  context "images" do
    it "should report success" do
      rsp = cptr("images:metadata:remove #{@img.name} aardvark kangaroo")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      rsp.stdout.should include("aardvark")
      rsp.stdout.should include("kangaroo")
      result = Images.new.get("#{@img.id}")
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should_not include("kangaroo")
      result.meta.to_s.should_not include("aardvark")
    end
  end

  context "images with valid avl" do
    it "should report success" do
      rsp = cptr("images:metadata:remove -z az-1.region-a.geo-1 #{@img.id} aardvark kangaroo")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      rsp.stdout.should include("Removed metadata 'aardvark' from image")
      rsp.stdout.should include("Removed metadata 'kangaroo' from image")
      result = Images.new.get("#{@img.id}")
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should_not include("kangaroo")
      result.meta.to_s.should_not include("aardvark")
    end
  end

  context "images with invalid avl" do
    it "should report error" do
      rsp = cptr("images:metadata:remove -z blah #{@img.id} aardvark kangaroo")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:metadata:remove -a bogus #{@img.id} something")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
