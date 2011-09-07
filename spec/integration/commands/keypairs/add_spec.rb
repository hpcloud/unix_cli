require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when creating keypair with name" do
    before(:all) do
      @response, @exit = run_command('keypairs:add mykey').stdout_and_exit_status
    end

    it "should show success message" do
      @response.should include("Created key pair 'mykey'.")
    end
    its_exit_status_should_be(:success)

    it "should list in keypairs" do
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include('mykey')
    end

    it "should have a name" do
      keypair = get_keypair(@hp_svc, 'mykey')
      keypair.name.should eql('mykey')
    end

    it "should have a fingerprint data" do
      keypair = get_keypair(@hp_svc, 'mykey')
      keypair.fingerprint.should_not be_nil
    end

    it "should report key exists if created again" do
      @response, @exit = run_command('keypairs:add mykey').stdout_and_exit_status
      @response.should eql("Key pair 'mykey' already exists.\n")
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, 'mykey')
      keypair.destroy if keypair
    end
  end

  context "when creating keypair with output flag" do
    before(:all) do
      @response, @exit = run_command('keypairs:add mykey2 -o').stdout_and_exit_status
    end
    it "should show success message" do
      @response.should include("Created key pair 'mykey2' and saved it in a file at './mykey2.pem'.")
    end
    its_exit_status_should_be(:success)

    it "should list in keypairs" do
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include('mykey2')
    end

    it "should have a name" do
      keypair = get_keypair(@hp_svc, 'mykey2')
      keypair.name.should eql('mykey2')
    end

    it "should have a fingerprint data" do
      keypair = get_keypair(@hp_svc, 'mykey2')
      keypair.fingerprint.should_not be_nil
    end

    after(:all) do
      keypair = get_keypair(@hp_svc, 'mykey2')
      keypair.destroy if keypair
      File.delete("./mykey2.pem") if File.exists?("./mykey2.pem")
    end
  end
end