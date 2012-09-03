require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @keypair_name = ('fog-serv-key-100')
    @sg_name = resource_name('fog-serv-sg-100')
    @keypair = @hp_svc.key_pairs.create(:name => @keypair_name)
    @sgroup = @hp_svc.security_groups.create(:name => @sg_name, :description => "#{@sg_name} desc")
  end

  context "when creating server with name, image and flavor (no keyname or security group)" do
    before(:all) do
      @server_name = resource_name("add1")
      @response, @exit = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
    end
    it "should list name in servers" do
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:all) do
      @hp_svc.delete_server(@new_server_id)
    end
  end
  context "when creating server with name, image, flavor, keyname and security group and metadata" do
    before(:all) do
      @server_name = resource_name("add2")
      @response, @exit = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -s #{@sg_name} -m E=mc2,PV=nRT").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      #@response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}', key '#{@keypair_name}' and security group '#{@sg_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
    end
    it "should list name in servers" do
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end
    it "should have the metadata" do
      servers = HP::Cloud::Servers.new.get([@new_server_id])
      servers.length.should eq(1)
      servers[0].meta.hsh['E'].should eq('mc2')
      servers[0].meta.hsh['PV'].should eq('nRT')
    end

    after(:all) do
      compute_connection.delete_server(@new_server_id)
    end
  end
  context "when creating server with name, image, flavor and only keyname" do
    before(:all) do
      @server_name = resource_name("add3")
      @response, @exit = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      #@response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}', and key '#{@keypair_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
    end
    it "should list name in servers" do
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:all) do
      compute_connection.delete_server(@new_server_id)
    end
  end
  context "when creating server with name, image, flavor and only security group" do
    before(:all) do
      @server_name = resource_name("add4")
      @response, @exit = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -s #{@sg_name}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      #@response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}', and security group '#{@sg_name}'.\n")
      rsp.exit_status.should be_exit(:success)
    end

    it "should list id in servers" do
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
    end
    it "should list name in servers" do
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:all) do
      @hp_svc.delete_server(@new_server_id)
    end
  end
  context "when creating server with a name that already exists" do
    before(:all) do
      @server_name = "server-already-exists"
      @server = @hp_svc.servers.create(:flavor_id => AccountsHelper.get_flavor_id(), :image_id => AccountsHelper.get_image_id(), :name => @server_name )
      @server.wait_for { ready? }
      # now create the server with the same name
      @response, @exit = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()}").stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("Server with the name '#{@server_name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      @hp_svc.delete_server(@server.id) unless @server.nil?
    end
  end
  context "when creating server with avl settings passed in" do
    before(:all) do
      @server_name = resource_name("add5")
    end
    context "servers:add with valid avl" do
      before(:all) do
        @response, @exit_status = run_command("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -z az-1.region-a.geo-1").stdout_and_exit_status
        @server_id2 = @response.scan(/'([^']+)/)[2][0]
      end
      it "should report success" do
        @response.should eql("Created server '#{@server_name}' with id '#{@server_id2}'.\n")
        rsp.exit_status.should be_exit(:success)
      end

      it "should list id in servers" do
        servers = @hp_svc.servers.map {|s| s.id}
        servers.should include(@server_id2.to_i)
      end
      it "should list name in servers" do
        servers = @hp_svc.servers.map {|s| s.name}
        servers.should include(@server_name)
      end
      after(:all) do
        @hp_svc.delete_server(@server_id2)
      end
    end
    context "servers:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("servers:add other_name #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.clear_options() }
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:add other_name #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @keypair.destroy if @keypair
    @sgroup.destroy if @sgroup
  end

end
