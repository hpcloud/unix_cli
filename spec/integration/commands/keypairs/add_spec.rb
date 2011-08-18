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
      @response, @exit = run_command('keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66').stdout_and_exit_status
    end

    it "should show success message" do
      @response.should eql("Created key pair 'mykey'.\n")
    end
    its_exit_status_should_be(:success)

    it "should list in keypairs" do
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include('mykey')
    end

    it "should report key exists if created again" do
      @response, @exit = run_command('keypairs:add mykey c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66').stdout_and_exit_status
      @response.should eql("Key pair 'mykey' already exists.\n")
    end

    after(:all) do
      keypair = @hp_svc.key_pairs.select {|k| k.name == 'mykey'}.first
      keypair.destroy if keypair
    end
  end
end