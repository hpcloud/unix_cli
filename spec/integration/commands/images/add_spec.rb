require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:add command" do
  before(:all) do
    @hp_svc = Connection.instance.compute
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()
  end

  context "when creating image with name, server and defaults" do
    it "should show success message" do
      @server_name = resource_name("iadd")
      @image_name = resource_name("add")
      @server = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name )
      @server.wait_for { ready? }

      rsp = cptr("images:add #{@image_name} #{@server_name} -m e=mc2,pv=nRT")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created image '#{@image_name}'")
      rsp.exit_status.should be_exit(:success)
      @new_image_id = @response.scan(/'([^']+)/)[2][0]
      images = @hp_svc.images.map {|i| i.id}
      images.should include(@new_image_id)
      images = @hp_svc.images.map {|i| i.name}
      images.should include(@image_name)
      images = Images.new.get([@new_image_id])
      images.length.should eq(1)
      images[0].meta.hsh['e'].should eq('mc2')
      images[0].meta.hsh['pv'].should eq('nRT')
    end

    after(:all) do
      #Connection.instance.compute.images.get(@new_image_id).destroy
      @server.destroy unless @server.nil?
    end
  end

  context "images:add with valid avl" do
    it "should report success" do
      @image_name2 = resource_name("add2")
      @server_name2 = resource_name("iadd2")
      @server2 = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name2 )
      @server2.wait_for { ready? }

      rsp = cptr("images:add #{@image_name2} #{@server_name2} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created image '#{@image_name2}'")
      rsp.exit_status.should be_exit(:success)
      @image_id2 = response.scan(/'([^']+)/)[2][0]
    end

    after(:all) do
      img = @hp_svc.images.get(@image_id2)
      img.destroy unless img.nil?
      @server2.destroy
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
      AccountsHelper.use_tmp()

      rsp = cptr("images:add -a bogus image_name server_name")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
