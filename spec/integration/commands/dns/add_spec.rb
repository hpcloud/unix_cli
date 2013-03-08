require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "dns:add command" do
  before(:all) do
    @hp_svc = HP::Cloud::Connection.instance.block
  end

  context "when creating dns with name description" do
    it "should show success message" do
      @dns_description = 'Add_dns'
      @dns_name = resource_name("add1")

      rsp = cptr("dns:add #{@dns_name} 1 -d #{@dns_description}")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns '#{@dns_name}' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      dnss = @hp_svc.dnss.map {|s| s.id}
      dnss.should include(@new_dns_id.to_i)
      dnss = @hp_svc.dnss.map {|s| s.name}
      dnss.should include(@dns_name)
      dnss = @hp_svc.dnss.map {|s| s.description}
      dnss.should include(@dns_description)
    end

    after(:each) do
      cptr("dns:remove #{@dns_name}")
    end
  end

  context "when creating dns with name with no desciption" do
    it "should show success message" do
      @dns_name = resource_name("add2")

      rsp = cptr("dns:add #{@dns_name} 1")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns '#{@dns_name}' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      dnss = @hp_svc.dnss.map {|s| s.id}
      dnss.should include(@new_dns_id.to_i)
      dnss = @hp_svc.dnss.map {|s| s.name}
      dnss.should include(@dns_name)
    end

    after(:each) do
      cptr("dns:remove #{@dns_name}")
    end
  end

  context "when creating dns from a snapshot" do
    it "should show success message" do
      @ds3= DnsTestHelper.create("cli_test_ds3")
      @snap2= SnapshotTestHelper.create("cli_test_snap2", @ds3)
      @dns_name = resource_name("add3")

      rsp = cptr("dns:add #{@dns_name} -s #{@snap2.name}")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns '#{@dns_name}' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      dnss = @hp_svc.dnss.map {|s| s.id}
      dnss.should include(@new_dns_id.to_i)
      dnss = @hp_svc.dnss.map {|s| s.name}
      dnss.should include(@dns_name)
    end

    after(:each) do
      cptr("dns:remove #{@dns_name}")
    end
  end

  context "when creating dns from an image" do
    it "should show success message" do
      image_id = AccountsHelper.get_image_id()
      @dns_name = resource_name("add4")

      rsp = cptr("dns:add #{@dns_name} 10 -i #{image_id}")

      rsp.stderr.should eq("")
      @new_dns_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created dns '#{@dns_name}' with id '#{@new_dns_id}'.\n")
      rsp.exit_status.should be_exit(:success)
      dnss = @hp_svc.dnss.map {|s| s.id}
      dnss.should include(@new_dns_id.to_i)
      dnss = @hp_svc.dnss.map {|s| s.name}
      dnss.should include(@dns_name)
    end

    after(:each) do
      cptr("dns:remove #{@dns_name}")
    end
  end

  context "when creating dns with a name that already exists" do
    it "should fail" do
      @ds1 = DnsTestHelper.create("cli_test_ds1")

      rsp = cptr("dns:add #{@ds1.name} 1")

      rsp.stderr.should eq("Dns with the name '#{@ds1.name}' already exists\n")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("dns:add dsler 1 -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
