require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'hpcloud/image_helper'

describe "Images command" do
  before(:all) do
    @srv = ServerTestHelper.create('srv1')

    @img = HP::Cloud::ImageHelper.new()
    @img.name = resource_name("meta_img")
    @img.set_server("#{@srv.name}")
    @img.meta.set_metadata('darth=vader,count=dooku')
    @img.save.should be_true
    @img = Images.new.get(@img.name)
  end

  describe "with avl settings from config" do
    context "images" do
      it "should report success" do
        rsp = cptr("images:metadata #{@img.id}")
        rsp.stderr.should eq("")
        rsp.stdout.should include("count")
        rsp.stdout.should include("dooku")
        rsp.stdout.should include("darth")
        rsp.stdout.should include("vader")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "images with name" do
      it "should report success" do
        rsp = cptr("images:metadata #{@img.name}")
        rsp.stderr.should eq("")
        rsp.stdout.should include("count")
        rsp.stdout.should include("dooku")
        rsp.stdout.should include("darth")
        rsp.stdout.should include("vader")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "images:metadata:list" do
      it "should report success" do
        rsp = cptr("images:metadata:list #{@img.name}")
        rsp.exit_status.should be_exit(:success)
      end
    end
  end

  describe "with avl settings passed in" do
    context "images with valid avl" do
      it "should report success" do
        rsp = cptr("images:metadata:list -z az-1.region-a.geo-1 #{@img.name}")
        rsp.stderr.should eq("")
        rsp.exit_status.should be_exit(:success)
      end
    end

    context "images with invalid avl" do
      it "should report error" do
        rsp = cptr("images:metadata -z blah #{@img.name}")
        rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        rsp.stdout.should eq("")
        rsp.exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:metadata -a bogus #{@img.name}")

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
