require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "snapshots:add command" do
  before(:all) do
    @vol = VolumeTestHelper.create("cli_test_vol2")
  end

  context "when creating snapshot with name description" do
    it "should show success message" do
      @snapshot_description = 'Add_snapshot'
      @snapshot_name = resource_name("add1")

      rsp = cptr("snapshots:add #{@snapshot_name} #{@vol.name} -d #{@snapshot_description}")

      rsp.stderr.should eq("")
      @new_snapshot_id = rsp.stdout.scan(/Created snapshot '#{@snapshot_name}' with id '([^']+)/)[2][0]
      rsp.exit_status.should be_exit(:success)
      snapshots = @hp_svc.snapshots.map {|s| s.id}
      snapshots.should include(@new_snapshot_id.to_i)
      snapshots = @hp_svc.snapshots.map {|s| s.name}
      snapshots.should include(@snapshot_name)
      snapshots = @hp_svc.snapshots.map {|s| s.description}
      snapshots.should include(@snapshot_description)
    end

    after(:all) do
      @hp_svc.delete_snapshot(@new_snapshot_id) unless @new_snapshot_id.nil?
    end
  end

  context "when creating snapshot with name with no desciption" do
    it "should show success message" do
      @snapshot_name = resource_name("add2")

      rsp = cptr("snapshots:add #{@snapshot_name} #{@vol.name}")

      rsp.stderr.should eq("")
      @new_snapshot_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created snapshot '#{@snapshot_name}' with id '#{@new_snapshot_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      snapshots = @hp_svc.snapshots.map {|s| s.id}
      snapshots.should include(@new_snapshot_id.to_i)
      snapshots = @hp_svc.snapshots.map {|s| s.name}
      snapshots.should include(@snapshot_name)
    end

    after(:all) do
      @hp_svc.delete_snapshot(@new_snapshot_id) unless @new_snapshot_id.nil?
    end
  end

  context "when creating snapshot with a name that already exists" do
    it "should fail" do
      #@snapshot1 = VolumeTestHelper.create("cli_test_snapshot1")

      rsp = cptr("snapshots:add #{@snapshot1.name} #{@vol.name}")

      rsp.stderr.should eq("Snapshot with the name '#{@snapshot1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("snapshots:add snappy #{@vol.name} 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
