require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "images:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = Connection.instance.compute
    @flavor_id = AccountsHelper.get_flavor_id()
    @image_id = AccountsHelper.get_image_id()
  end

  context "when creating image with name, server and defaults" do
    before(:all) do
      @server_name = resource_name("iadd")
      @image_name = resource_name("add")
      @server = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name )
      @server.wait_for { ready? }

      @response, @exit = run_command("images:add #{@image_name} #{@server_name} -m e=mc2,pv=nRT").stdout_and_exit_status
      @new_image_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should include("Created image '#{@image_name}'")
    end
    its_exit_status_should_be(:success)

    it "should list id in images" do
      images = @hp_svc.images.map {|i| i.id}
      images.should include(@new_image_id)
    end
    it "should list name in images" do
      images = @hp_svc.images.map {|i| i.name}
      images.should include(@image_name)
    end
    it "should have the metadata" do
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

  context "with avl settings passed in" do
    before(:all) do
      @image_name2 = resource_name("add2")
      @server_name2 = resource_name("iadd2")
    end
    context "images:add with valid avl" do
      before(:all) do
        @server2 = @hp_svc.servers.create(:flavor_id => @flavor_id, :image_id => @image_id, :name => @server_name2 )
        @server2.wait_for { ready? }
      end
      it "should report success" do
        response, exit_status = run_command("images:add #{@image_name2} #{@server_name2} -z az-1.region-a.geo-1").stdout_and_exit_status
        @image_id2 = response.scan(/'([^']+)/)[2][0]
        response.should include("Created image '#{@image_name2}'")
        exit_status.should be_exit(:success)

      end
      after(:all) do
        img = @hp_svc.images.get(@image_id2)
        img.destroy unless img.nil?
        @server2.destroy
      end
    end
    context "images:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("images:add #{@image_name2} #{@server_name2} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
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
