require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "keypairs:add command" do

  before(:all) do
    @hp_svc = compute_connection
    @fingerprint = "c1:db:b5:bc:8b:b9:0f:33:62:53:de:80:6e:ae:67:66"
    @private_data = "some_real_private_data"
  end

  context "when creating a keypair with name" do
    it "should show success message" do
      @key_name = resource_name('cli_test_add1')

      rsp = cptr("keypairs:add #{@key_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created key pair '#{@key_name}'.")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
      rsp = cptr("keypairs:add #{@key_name}")
      rsp.stderr.should eq("Key pair '#{@key_name}' already exists.\n")
    end

    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name and fingerprint" do
    it "should list in keypairs" do
      @key_name = resource_name('cli_test_add2')

      rsp = cptr("keypairs:add #{@key_name} -f #{@fingerprint}")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
    end

    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name and private data" do
    it "should list in keypairs" do
      @key_name = resource_name('cli_test_add3')

      rsp = cptr("keypairs:add #{@key_name} -p #{@private_data}")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
    end

    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with name, fingerprint and private data" do
    it "should list in keypairs" do
      @key_name = resource_name('cli_test_add4')

      rsp = cptr("keypairs:add #{@key_name} -f #{@fingerprint} -p #{@private_data}")

      rsp.stderr.should eq("")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
    end

    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "when creating a keypair with output flag" do
    it "should show success message" do
      @key_name = resource_name('cli_test_add5')

      rsp = cptr("keypairs:add #{@key_name} -o")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created key pair '#{@key_name}' and saved it to a file at '#{ENV['HOME']}/.hpcloud/keypairs/#{@key_name}.pem'.")
      rsp.exit_status.should be_exit(:success)
      keypairs = @hp_svc.key_pairs.map {|kp| kp.name}
      keypairs.should include(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.name.should eql(@key_name)
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.fingerprint.should_not be_nil
      @filename = "#{ENV['HOME']}/.hpcloud/keypairs/#{@key_name}.pem"
      File.exists?(@filename).should be_true
    end

    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
      File.delete(@filename) if File.exists?(@filename)
    end
  end

  context "keypairs:add with valid avl" do
    it "should report success" do
      @key_name = resource_name('cli_test_add6')

      rsp = cptr("keypairs:add #{@key_name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created key pair '#{@key_name}'.")
      rsp.exit_status.should be_exit(:success)
    end
    after(:each) do
      keypair = get_keypair(@hp_svc, @key_name)
      keypair.destroy if keypair
    end
  end

  context "keypairs:add with invalid avl" do
    it "should report error" do
      rsp = cptr("keypairs:add some_key_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("keypairs:add -a bogus nameo")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
