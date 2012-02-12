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
      @server_name = resource_name("add")
      @response, @exit = run_command("servers:add #{@server_name} #{OS_COMPUTE_BASE_IMAGE_ID} #{OS_COMPUTE_BASE_FLAVOR_ID}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}'.\n")
    end
    its_exit_status_should_be(:success)

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
  context "when creating server with name, image, flavor, keyname and security group" do
    before(:all) do
      @server_name = resource_name("add")
      @response, @exit = run_command("servers:add #{@server_name} #{OS_COMPUTE_BASE_IMAGE_ID} #{OS_COMPUTE_BASE_FLAVOR_ID} #{@keypair_name} #{@sg_name}").stdout_and_exit_status
      @new_server_id = @response.scan(/'([^']+)/)[2][0]
    end

    it "should show success message" do
      @response.should eql("Created server '#{@server_name}' with id '#{@new_server_id}', key '#{@keypair_name}' and security group '#{@sg_name}'.\n")
    end
    its_exit_status_should_be(:success)

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
  context "when creating server with name, image, flavor and only keyname" do
    before(:all) do
      @server_name = resource_name("add")
      @response, @exit = run_command("servers:add #{@server_name} #{OS_COMPUTE_BASE_IMAGE_ID} #{OS_COMPUTE_BASE_FLAVOR_ID} #{@keypair_name}").stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You need to specify both a key name and a security group.\n")
    end
    its_exit_status_should_be(:incorrect_usage)
  end
  context "when creating server with name, image, flavor and only security group" do
    before(:all) do
      @server_name = resource_name("add")
      @response, @exit = run_command("servers:add #{@server_name} #{OS_COMPUTE_BASE_IMAGE_ID} #{OS_COMPUTE_BASE_FLAVOR_ID} #{@sg_name}").stderr_and_exit_status
    end

    it "should show error message" do
      @response.should eql("You need to specify both a key name and a security group.\n")
    end
    its_exit_status_should_be(:incorrect_usage)
  end

  after(:all) do
    @keypair.destroy if @keypair
    @sgroup.destroy if @sgroup
  end

end