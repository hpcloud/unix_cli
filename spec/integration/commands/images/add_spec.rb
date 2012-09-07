require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:add command" do
  before(:all) do
    @hp_svc = Connection.instance.compute
  end

  context "when creating image with name, server and defaults" do
    it "should show success message" do
      @image_name = resource_name("add")
      @server = ServerTestHelper.create('cli_test_srv1')

      rsp = cptr("images:add #{@image_name} #{@server.name} -m e=mc2,pv=nRT")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created image '#{@image_name}'")
      rsp.exit_status.should be_exit(:success)
      @new_image_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      images = @hp_svc.images.map {|i| i.id}
      images.should include(@new_image_id)
      images = @hp_svc.images.map {|i| i.name}
      images.should include(@image_name)
      images = Images.new.get([@new_image_id])
      images.length.should eq(1)
      images[0].meta.hsh['e'].should eq('mc2')
      images[0].meta.hsh['pv'].should eq('nRT')
    end

    after(:each) do
      cptr("images:remove #{@image_name}")
    end
  end

  context "images:add with valid avl" do
    it "should report success" do
      @image_name = resource_name("add2")
      @server = ServerTestHelper.create('cli_test_srv2')

      rsp = cptr("images:add #{@image_name} #{@server.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created image '#{@image_name}'")
      rsp.exit_status.should be_exit(:success)
      @image_id2 = rsp.stdout.scan(/'([^']+)/)[2][0]
    end

    after(:each) do
      cptr("images:remove #{@image_name}")
    end
  end

  context "images:add with invalid avl" do
    it "should report error" do
      rsp = cptr("images:add image server -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      @server = ServerTestHelper.create('cli_test_srv3')
      AccountsHelper.use_tmp()

      rsp = cptr("images:add -a bogus image_name #{@server.name}")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
