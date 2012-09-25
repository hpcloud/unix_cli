require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "snapshots:add command" do
  before(:all) do
    @vol = VolumeTestHelper.create("cli_test_vol2")
    @hp_svc = Connection.instance.block
  end

  context "when creating snapshot with name description" do
    it "should show success message" do
      @snapshot_description = 'Add_snapshot'
      @snapshot_name = resource_name("add1")

      rsp = cptr("snapshots:add #{@snapshot_name} #{@vol.name} -d #{@snapshot_description}")

      rsp.stderr.should eq("")
      @new_snapshot_id = rsp.stdout.scan(/Created snapshot '#{@snapshot_name}' from volume with id '([^']+)/)[0][0]
      rsp.exit_status.should be_exit(:success)
      snappy = @hp_svc.snapshots
      snappy = snappy.select {|s| s.id.to_s == @new_snapshot_id }.first
      snappy.name.should eq(@snapshot_name)
      snappy.description.should eq(@snapshot_description)
    end

    after(:all) do
      @hp_svc.snapshots.get(@new_snapshot_id).destroy unless @new_snapshot_id.nil?
    end
  end

  context "when creating snapshot with name with no desciption" do
    it "should show success message" do
      @snapshot_name = resource_name("add2")

      rsp = cptr("snapshots:add #{@snapshot_name} #{@vol.name}")

      rsp.stderr.should eq("")
      @new_snapshot_id = rsp.stdout.scan(/Created snapshot '#{@snapshot_name}' from volume with id '([^']+)/)[0][0]
      rsp.exit_status.should be_exit(:success)
      snappy = @hp_svc.snapshots
      snappy = snappy.select {|s| s.id.to_s == @new_snapshot_id }.first
      snappy.name.should eq(@snapshot_name)
      snappy.description.should be_nil
    end

    after(:all) do
      @hp_svc.snapshots.get(@new_snapshot_id).destroy unless @new_snapshot_id.nil?
    end
  end

  context "when creating snapshot with a name that already exists" do
    it "should fail" do
      @snapshot1 = SnapshotTestHelper.create("cli_test_snapshot1", @vol)

      rsp = cptr("snapshots:add #{@snapshot1.name} #{@vol.name}")

      rsp.stderr.should eq("Snapshot with the name '#{@snapshot1.name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "Create a snap shot with a bad volume name" do
    it "should report error" do
      rsp = cptr("snapshots:add snappy bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Cannot find volume 'bogus'\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("snapshots:add snappy #{@vol.name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
