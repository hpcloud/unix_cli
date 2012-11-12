require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:add command" do
  before(:all) do
    @hp_svc = HP::Cloud::Connection.instance.block
  end

  context "when creating volume with name description" do
    it "should show success message" do
      @volume_description = 'Add_volume'
      @volume_name = resource_name("add1")

      rsp = cptr("volumes:add #{@volume_name} 1 -d #{@volume_description}")

      rsp.stderr.should eq("")
      @new_volume_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
      volumes = @hp_svc.volumes.map {|s| s.description}
      volumes.should include(@volume_description)
    end

    after(:each) do
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "when creating volume with name with no desciption" do
    it "should show success message" do
      @volume_name = resource_name("add2")

      rsp = cptr("volumes:add #{@volume_name} 1")

      rsp.stderr.should eq("")
      @new_volume_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
    end

    after(:each) do
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "when creating volume from a snapshot" do
    it "should show success message" do
      @vol3= VolumeTestHelper.create("cli_test_vol3")
      @snap2= SnapshotTestHelper.create("cli_test_snap2", @vol3)
      @volume_name = resource_name("add3")

      rsp = cptr("volumes:add #{@volume_name} -s #{@snap2.name}")

      rsp.stderr.should eq("")
      @new_volume_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
    end

    after(:each) do
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "when creating volume from an image" do
    it "should show success message" do
      image_id = AccountsHelper.get_image_id()
      @volume_name = resource_name("add4")

      rsp = cptr("volumes:add #{@volume_name} -i #{image_id}")

      rsp.stderr.should eq("")
      @new_volume_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created volume '#{@volume_name}' with id '#{@new_volume_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      volumes = @hp_svc.volumes.map {|s| s.id}
      volumes.should include(@new_volume_id.to_i)
      volumes = @hp_svc.volumes.map {|s| s.name}
      volumes.should include(@volume_name)
    end

    after(:each) do
      cptr("volumes:remove #{@volume_name}")
    end
  end

  context "when creating volume with a name that already exists" do
    it "should fail" do
      @vol1 = VolumeTestHelper.create("cli_test_vol1")

      rsp = cptr("volumes:add #{@vol1.name} 1")

      rsp.stderr.should eq("Volume with the name '#{@vol1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:add voller 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
