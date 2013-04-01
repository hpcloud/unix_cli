require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "networks:add command" do
  context "when creating network" do
    it "should show success message" do
      @networks_name = resource_name("add1")

      rsp = cptr("networks:add #{@networks_name}")

      rsp.stderr.should eq("")
      @new_networks_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created networks '#{@networks_name}' with id '#{@new_networks_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      networks = @hp_svc.networks.map {|s| s.id}
      networks.should include(@new_networks_id.to_i)
      networks = @hp_svc.networks.map {|s| s.name}
      networks.should include(@networks_name)
      networks = @hp_svc.networks.map {|s| s.description}
      networks.should include(@networks_description)
    end

    after(:each) do
      cptr("networks:remove #{@networks_name}")
    end
  end

  context "when creating networks with name with no desciption" do
    it "should show success message" do
      @networks_name = resource_name("add2")

      rsp = cptr("networks:add #{@networks_name} 1")

      rsp.stderr.should eq("")
      @new_networks_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created networks '#{@networks_name}' with id '#{@new_networks_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      networks = @hp_svc.networks.map {|s| s.id}
      networks.should include(@new_networks_id.to_i)
      networks = @hp_svc.networks.map {|s| s.name}
      networks.should include(@networks_name)
    end

    after(:each) do
      cptr("networks:remove #{@networks_name}")
    end
  end

  context "when creating networks from a snapshot" do
    it "should show success message" do
      @ds3= NetworkTestHelper.create("cli_test_ds3")
      @snap2= SnapshotTestHelper.create("cli_test_snap2", @ds3)
      @networks_name = resource_name("add3")

      rsp = cptr("networks:add #{@networks_name} -s #{@snap2.name}")

      rsp.stderr.should eq("")
      @new_networks_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created networks '#{@networks_name}' with id '#{@new_networks_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      networks = @hp_svc.networks.map {|s| s.id}
      networks.should include(@new_networks_id.to_i)
      networks = @hp_svc.networks.map {|s| s.name}
      networks.should include(@networks_name)
    end

    after(:each) do
      cptr("networks:remove #{@networks_name}")
    end
  end

  context "when creating networks from an image" do
    it "should show success message" do
      image_id = AccountsHelper.get_image_id()
      @networks_name = resource_name("add4")

      rsp = cptr("networks:add #{@networks_name} 10 -i #{image_id}")

      rsp.stderr.should eq("")
      @new_networks_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created networks '#{@networks_name}' with id '#{@new_networks_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      networks = @hp_svc.networks.map {|s| s.id}
      networks.should include(@new_networks_id.to_i)
      networks = @hp_svc.networks.map {|s| s.name}
      networks.should include(@networks_name)
    end

    after(:each) do
      cptr("networks:remove #{@networks_name}")
    end
  end

  context "when creating networks with a name that already exists" do
    it "should fail" do
      @ds1 = NetworkTestHelper.create("cli_test_ds1")

      rsp = cptr("networks:add #{@ds1.name} 1")

      rsp.stderr.should eq("Network with the name '#{@ds1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("networks:add dsler 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
