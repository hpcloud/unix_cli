require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:import command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
    @fake_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDb10XnajM1H7amPuG0P0lY34B1ZRQMTheX9lUBqMNnjzbY67LSP9cGUKaBEGlyboMavtY27vvG2qmFhzwcPsJBNcBhboTX4RCWyzFMp588tgkXq9RLdJ1DufysNvqvLc9V4N5ZjTl6soOjSYl71XVJs08LWXM4NljR1dT9kYb2nw== nova@use03147k5-eth0"
  end

  context "when importing a keypair" do
    before(:all) do
      @key_name = 'fog-imp-200'
      @response, @exit = capture_with_status(:stdout){ HP::Cloud::CLI.start(['keypairs:import', @key_name, @fake_public_key]) }
    end

    it "should show success message" do
      @response.should eql("Imported key pair '#{@key_name}'.\n")
    end
    its_exit_status_should_be(:success)

    it "should list in keypairs" do
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
    end

    it "should have a name" do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
    end

    it "should have a fingerprint data" do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
    end

    it "should report key exists if imported again" do
      @response, @exit = capture_with_status(:stderr){ HP::Cloud::CLI.start(['keypairs:import', @key_name, @fake_public_key]) }
      @response.should eql("Key pair '#{@key_name}' already exists.\n")
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when importing a keypair with avl settings passed in" do
    before(:all) do
      @key_name = 'fog-imp-201'
    end
    context "keypairs:import with valid avl" do
      it "should report success" do
        response, exit_status = capture_with_status(:stdout){ HP::Cloud::CLI.start(['keypairs:import', @key_name, @fake_public_key, '-z', 'az-1.region-a.geo-1']) }
        #response, exit_status = run_command("keypairs:add #{@key_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should include("Imported key pair '#{@key_name}'.\n")
        exit_status.should be_exit(:success)
      end
      after(:all) do
        keypair = get_keypair(@hp_svc, @key_name)
        keypair.destroy if keypair
      end
    end
    context "keypairs:import with invalid avl" do
      it "should report error" do
        response, exit_status = capture_with_status(:stderr){ HP::Cloud::CLI.start(['keypairs:import', @key_name, @fake_public_key, '-z', 'blah']) }
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { Connection.instance.clear_options() }
    end
  end

end
