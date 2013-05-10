require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:add command" do
  before(:all) do
    @hp_svc = HP::Cloud::Connection.instance.block
  end

  context "when creating lb with name description" do
    it "should show success message" do
      @lb_description = 'Add_lb'
      @lb_name = resource_name("add1")

      rsp = cptr("lb:add #{@lb_name} 1 -d #{@lb_description}")

      rsp.stderr.should eq("")
      @new_lb_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lb '#{@lb_name}' with id '#{@new_lb_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbs = @hp_svc.lbs.map {|s| s.id}
      lbs.should include(@new_lb_id.to_i)
      lbs = @hp_svc.lbs.map {|s| s.name}
      lbs.should include(@lb_name)
      lbs = @hp_svc.lbs.map {|s| s.description}
      lbs.should include(@lb_description)
    end

    after(:each) do
      cptr("lb:remove #{@lb_name}")
    end
  end

  context "when creating lb with name with no desciption" do
    it "should show success message" do
      @lb_name = resource_name("add2")

      rsp = cptr("lb:add #{@lb_name} 1")

      rsp.stderr.should eq("")
      @new_lb_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lb '#{@lb_name}' with id '#{@new_lb_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbs = @hp_svc.lbs.map {|s| s.id}
      lbs.should include(@new_lb_id.to_i)
      lbs = @hp_svc.lbs.map {|s| s.name}
      lbs.should include(@lb_name)
    end

    after(:each) do
      cptr("lb:remove #{@lb_name}")
    end
  end

  context "when creating lb from a snapshot" do
    it "should show success message" do
      @lbs3= LbTestHelper.create("cli_test_lbs3")
      @snap2= SnapshotTestHelper.create("cli_test_snap2", @lbs3)
      @lb_name = resource_name("add3")

      rsp = cptr("lb:add #{@lb_name} -s #{@snap2.name}")

      rsp.stderr.should eq("")
      @new_lb_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lb '#{@lb_name}' with id '#{@new_lb_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbs = @hp_svc.lbs.map {|s| s.id}
      lbs.should include(@new_lb_id.to_i)
      lbs = @hp_svc.lbs.map {|s| s.name}
      lbs.should include(@lb_name)
    end

    after(:each) do
      cptr("lb:remove #{@lb_name}")
    end
  end

  context "when creating lb from an image" do
    it "should show success message" do
      image_id = AccountsHelper.get_image_id()
      @lb_name = resource_name("add4")

      rsp = cptr("lb:add #{@lb_name} 10 -i #{image_id}")

      rsp.stderr.should eq("")
      @new_lb_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created lb '#{@lb_name}' with id '#{@new_lb_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      lbs = @hp_svc.lbs.map {|s| s.id}
      lbs.should include(@new_lb_id.to_i)
      lbs = @hp_svc.lbs.map {|s| s.name}
      lbs.should include(@lb_name)
    end

    after(:each) do
      cptr("lb:remove #{@lb_name}")
    end
  end

  context "when creating lb with a name that already exists" do
    it "should fail" do
      @lbs1 = LbTestHelper.create("cli_test_lbs1")

      rsp = cptr("lb:add #{@lbs1.name} 1")

      rsp.stderr.should eq("Lb with the name '#{@lbs1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lb:add lbsler 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
