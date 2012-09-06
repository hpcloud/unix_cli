require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:remove command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()
  end

  context "when deleting an image by name" do
    before(:all) do
      @image_name = resource_name("del")
      @server_name = resource_name("idel")
      @server = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name )
      @server.wait_for { ready? }

      resp = @server.create_image(@image_name)
      sleep(10)
      @new_image_id = resp.headers["Location"].split("/")[5]
    end

    it "should show success message" do
      rsp = cptr("images:remove #{@image_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed image '#{@image_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      sleep(10)
      images = @hp_svc.images.map {|i| i.id}
      images.should_not include(@new_image_id)
      image = @hp_svc.images.get(@new_image_id)
      image.should be_nil
    end

    after(:all) do
      @server.destroy
    end
  end

  context "images:add with valid avl" do
    before(:all) do
      @image_name2 = resource_name("del2")
      @server_name2 = resource_name("idel2")
      @server2 = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name2 )
      @server2.wait_for { ready? }
      resp = @server2.create_image(@image_name2)
      sleep(10)
      @image_id2 = resp.headers["Location"].split("/")[5]
    end
    it "should report success" do
      rsp = cptr("images:remove #{@image_name2} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed image '#{@image_name2}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
    after(:all) do
      @server2.destroy
    end
  end

  context "images:add with invalid avl" do
    it "should report error" do
      rsp = cptr("images:remove imgur -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "images:remove with invalid image" do
    it "should report error" do
      rsp = cptr("images:remove bogus")
      rsp.stderr.should eq("Cannot find a image matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("images:remove -a bogus bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
