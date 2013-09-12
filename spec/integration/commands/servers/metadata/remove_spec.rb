require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')
require 'hpcloud/server_helper'

describe "Servers metadata remove command" do
  before(:all) do
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()

    @srv = HP::Cloud::ServerHelper.new(Connection.instance.compute)
    @srv.name = resource_name("meta_srv")
    @srv.flavor = @flavor_id
    @srv.image = @image_id
    @srv.meta.set_metadata('one=1,two=2,three=3,four=4,five=5,six=6,seven=7,luke=skywalker,han=solo,aardvark=a,kangaroo=b')
    @srv.save.should be_true
    @srv.fog.wait_for { ready? }

    @server_id = "#{@srv.id}"
    @server_name = @srv.name
  end

  def still_contains_original(metastr)
    metastr.should include("luke=skywalker")
    metastr.should include("han=solo")
  end

  context "delete one" do
    it "should report success" do
      rsp = cptr("servers:metadata:remove #{@server_id} one")

      rsp.stderr.should eq("")
      rsp.stdout.should include("one")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should include("kangaroo=b")
      result.meta.to_s.should_not include("one")
    end
  end

  context "delete two" do
    it "should report success" do
      rsp = cptr("servers:metadata:remove #{@server_name} two five")

      rsp.stderr.should eq("")
      rsp.stdout.should include("two")
      rsp.stdout.should include("five")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should_not include("five")
      result.meta.to_s.should_not include("two")
    end
  end

  context "servers with valid avl" do
    it "should report success" do
      rsp = cptr("servers:metadata:remove -z region-b.geo-1 #{@server_id} three six")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Removed metadata 'three' from server")
      rsp.stdout.should include("Removed metadata 'six' from server")
      rsp.exit_status.should be_exit(:success)
      result = Servers.new.get(@server_id)
      still_contains_original(result.meta.to_s)
      result.meta.to_s.should_not include("six")
      result.meta.to_s.should_not include("three")
    end
  end

  context "servers with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:metadata:remove -z blah #{@server_id} four seven")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:metadata:remove #{@server_id} aardvark kangaroo -a bogus")

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
