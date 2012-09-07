require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images metadata update command" do
  before(:all) do
    @srv = ServerTestHelper.create('cli_test_srv1')
    @img = ImageTestHelper.create("cli_test_img1", @srv)
  end

  describe "with avl settings from config" do
    context "images" do
      it "should report success" do
        rsp = cptr("images:metadata:update #{@img.id} luke=l000001,han=h000001")

        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
        result = Images.new.get("#{@img.id}")
        result.meta.to_s.should include("luke=l000001")
        result.meta.to_s.should include("han=h000001")
      end
    end

    context "images" do
      it "should report success" do
        rsp = cptr("images:metadata:update #{@img.name} luke=l000002,han=h000002")

        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
        result = Images.new.get("#{@img.id}")
        result.meta.to_s.should include("luke=l000002")
        result.meta.to_s.should include("han=h000002")
      end
    end

  end

  context "images with valid avl" do
    it "should report success" do
      rsp = cptr("images:metadata:update -z az-1.region-a.geo-1 #{@img.id} luke=l000003,han=h000003")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      result = Images.new.get("#{@img.id}")
      result.meta.to_s.should include("luke=l000003")
      result.meta.to_s.should include("han=h000003")
    end
  end

  context "images with invalid avl" do
    it "should report error" do
      rsp = cptr("images:metadata:update -z blah #{@img.id} blah1=1,blah2=2")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:metadata:update -a bogus #{@img.id} blah1=1,blah2=2")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
