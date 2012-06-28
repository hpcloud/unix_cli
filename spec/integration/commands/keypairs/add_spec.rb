require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:add command" do

  before(:all) do
    @hp_svc = compute_connection
    @fingerprint = "c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66"
    @private_data = "some_real_private_data"
  end

  context "when creating a keypair with name" do
    before(:all) do
      @key_name = 'fog-key-200'
      @response, @exit = run_command("keypairs:add #{@key_name}").stdout_and_exit_status
    end

    it "should show success message" do
      @response.should include("Created key pair '#{@key_name}'.")
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

    it "should report key exists if created again" do
      @response, @exit = run_command("keypairs:add #{@key_name}").stderr_and_exit_status
      @response.should eql("Key pair '#{@key_name}' already exists.\n")
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name and fingerprint" do
    before(:all) do
      @key_name = 'fog-key-201'
      @response, @exit = run_command("keypairs:add #{@key_name} -f #{@fingerprint}").stdout_and_exit_status
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

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name and private data" do
    before(:all) do
      @key_name = 'fog-key-202'
      @response, @exit = run_command("keypairs:add #{@key_name} -p #{@private_data}").stdout_and_exit_status
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

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name, fingerprint and private data" do
    before(:all) do
      @key_name = 'fog-key-203'
      @response, @exit = run_command("keypairs:add #{@key_name} -f #{@fingerprint} -p #{@private_data}").stdout_and_exit_status
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

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with output flag" do
    before(:all) do
      @key_name = 'fog-key-204'
      @response, @exit = run_command("keypairs:add #{@key_name} -o").stdout_and_exit_status
    end
    it "should show success message" do
      @response.should include("Created key pair '#{@key_name}' and saved it to a file at './#{@key_name}.pem'.")
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

    after(:all) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
      File.delete("./#{@key_name}.pem") if File.exists?("./#{@key_name}.pem")
    end
  end

  context "when creating a keypair with avl settings passed in" do
    before(:all) do
      @key_name = 'fog-key-205'
    end
    context "keypairs:add with valid avl" do
      it "should report success" do
        response, exit_status = run_command("keypairs:add #{@key_name} -z az-1.region-a.geo-1").stdout_and_exit_status
        response.should include("Created key pair '#{@key_name}'.")
        exit_status.should be_exit(:success)
      end
      after(:all) do
        keypair = get_keypair(@hp_svc, @key_name)
        keypair.destroy if keypair
      end
    end
    context "keypairs:add with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("keypairs:add #{@key_name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end
    end
  end

end