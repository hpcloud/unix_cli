require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lbaas:add command" do
  before(:all) do
    @hp_svc = HP::Cloud::Connection.instance.block
  end

  context "when creating lbaas with name description" do
    it "should show success message" do
      @lbaas_description = 'Add_lbaas'
      @lbaas_name = resource_name("add1")

      rsp = cptr("lbaas:add #{@lbaas_name} 1 -d #{@lbaas_description}")

      rsp.stderr.should eq("")
      @new_lbaas_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lbaas '#{@lbaas_name}' with id '#{@new_lbaas_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbaass = @hp_svc.lbaass.map {|s| s.id}
      lbaass.should include(@new_lbaas_id.to_i)
      lbaass = @hp_svc.lbaass.map {|s| s.name}
      lbaass.should include(@lbaas_name)
      lbaass = @hp_svc.lbaass.map {|s| s.description}
      lbaass.should include(@lbaas_description)
    end

    after(:each) do
      cptr("lbaas:remove #{@lbaas_name}")
    end
  end

  context "when creating lbaas with name with no desciption" do
    it "should show success message" do
      @lbaas_name = resource_name("add2")

      rsp = cptr("lbaas:add #{@lbaas_name} 1")

      rsp.stderr.should eq("")
      @new_lbaas_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lbaas '#{@lbaas_name}' with id '#{@new_lbaas_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbaass = @hp_svc.lbaass.map {|s| s.id}
      lbaass.should include(@new_lbaas_id.to_i)
      lbaass = @hp_svc.lbaass.map {|s| s.name}
      lbaass.should include(@lbaas_name)
    end

    after(:each) do
      cptr("lbaas:remove #{@lbaas_name}")
    end
  end

  context "when creating lbaas from a snapshot" do
    it "should show success message" do
      @lbs3= LbaasTestHelper.create("cli_test_lbs3")
      @snap2= SnapshotTestHelper.create("cli_test_snap2", @lbs3)
      @lbaas_name = resource_name("add3")

      rsp = cptr("lbaas:add #{@lbaas_name} -s #{@snap2.name}")

      rsp.stderr.should eq("")
      @new_lbaas_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lbaas '#{@lbaas_name}' with id '#{@new_lbaas_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbaass = @hp_svc.lbaass.map {|s| s.id}
      lbaass.should include(@new_lbaas_id.to_i)
      lbaass = @hp_svc.lbaass.map {|s| s.name}
      lbaass.should include(@lbaas_name)
    end

    after(:each) do
      cptr("lbaas:remove #{@lbaas_name}")
    end
  end

  context "when creating lbaas from an image" do
    it "should show success message" do
      image_id = AccountsHelper.get_image_id()
      @lbaas_name = resource_name("add4")

      rsp = cptr("lbaas:add #{@lbaas_name} 10 -i #{image_id}")

      rsp.stderr.should eq("")
      @new_lbaas_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lbaas '#{@lbaas_name}' with id '#{@new_lbaas_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbaass = @hp_svc.lbaass.map {|s| s.id}
      lbaass.should include(@new_lbaas_id.to_i)
      lbaass = @hp_svc.lbaass.map {|s| s.name}
      lbaass.should include(@lbaas_name)
    end

    after(:each) do
      cptr("lbaas:remove #{@lbaas_name}")
    end
  end

  context "when creating lbaas with a name that already exists" do
    it "should fail" do
      @lbs1 = LbaasTestHelper.create("cli_test_lbs1")

      rsp = cptr("lbaas:add #{@lbs1.name} 1")

      rsp.stderr.should eq("Lbaas with the name '#{@lbs1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lbaas:add lbsler 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
