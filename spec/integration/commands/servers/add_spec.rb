require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "servers:add command" do
  before(:all) do
    @hp_svc = compute_connection
    @sg_name = 'cli_test_sg1'
    @keypair_name = 'cli_test_keypair1'
    SecurityGroupTestHelper.create(@sg_name)
    KeypairTestHelper.create(@keypair_name)
  end

  context "when creating server with name, image and flavor (no keyname or security group)" do
    it "should show success message" do
      @server_name = resource_name("add1")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating server with name, image, flavor, keyname and security group and metadata" do
    it "should show success message" do
      @server_name = resource_name("add2")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -s #{@sg_name} -m E=mc2,PV=nRT")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
      servers = HP::Cloud::Servers.new.get([@new_server_id])
      servers.length.should eq(1)
      servers[0].meta.hsh['E'].should eq('mc2')
      servers[0].meta.hsh['PV'].should eq('nRT')
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating server with name, image, flavor, keypair and only security group" do
    it "should show success message" do
      @server_name = resource_name("add4")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()}  -k #{@keypair_name} -s #{@sg_name}")

      rsp.stderr.should eq("")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating windows image server" do
    it "should show success message" do
      @server_name = resource_name("add5")
      @pem_file = Dir.home + "/.ssh/id_rsa"

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_win_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -p #{@pem_file}")

      rsp.stderr.should eq("\n")
      @new_server_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should include("Created server '#{@server_name}' with id '#{@new_server_id}'.\nRetrieving password, this may take several minutes...\nWindows password: ")
      rsp.exit_status.should be_exit(:success)
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@new_server_id.to_i)
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "when creating windows image server with bogus pem" do
    it "should show failure message" do
      @server_name = resource_name("add5")
      @pem_file = "bogus.pem"

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_win_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -p #{@pem_file}")

      rsp.stderr.should eq("Error reading private key file 'bogus.pem': No such file or directory - bogus.pem\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when creating windows image server with no pem" do
    it "should show failure message" do
      @server_name = resource_name("add5")
      @pem_file = "bogus.pem"

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_win_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("You must specify the private key file if you want to create a windows instance\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:incorrect_usage)
    end
  end

  context "when creating server with a name that already exists" do
    before(:all) do
      ServerTestHelper.create("cli_test_srv1")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name}")

      rsp.stderr.should eq("Server with the name '#{@server_name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "servers:add with valid avl" do
    it "should report success" do
      @server_name = resource_name("add5")

      rsp = cptr("servers:add #{@server_name} #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      @server_id2 = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created server '#{@server_name}' with id '#{@server_id2}'.\n")
      rsp.exit_status.should be_exit(:success)
      servers = @hp_svc.servers.map {|s| s.id}
      servers.should include(@server_id2.to_i)
      servers = @hp_svc.servers.map {|s| s.name}
      servers.should include(@server_name)
    end

    after(:each) do
      cptr("servers:remove #{@server_name}")
    end
  end

  context "servers:add with invalid avl" do
    it "should report error" do
      rsp = cptr("servers:add other_name #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "verify the -k option is mandatory" do
    it "should report error" do
      rsp = cptr("servers:add other_name #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()}")

      rsp.stderr.should eq("No value provided for required options '--key-name'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("servers:add other_name #{AccountsHelper.get_image_id()} #{AccountsHelper.get_flavor_id()} -k #{@keypair_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    @keypair.destroy if @keypair
  end
end
