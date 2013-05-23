require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "routers:add" do
  before(:each) do
    @network = NetworkTestHelper.create("Ext-Net")
    @routers_name = "routerone"
  end

  context "when creating router" do
    it "should show success message" do
      cptr("routers:remove #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name}")

      rsp.stderr.should eq("")
      @new_routers_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created router '#{@routers_name}' with id '#{@new_routers_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "router:add with all the options" do
    it "should show success message" do
      cptr("routers:remove #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name} -g #{@network.id} -u")

      rsp.stderr.should eq("")
      @new_routers_id = rsp.stdout.scan(/'([^']+)/)[2][0]
      rsp.stdout.should eq("Created router '#{@routers_name}' with id '#{@new_routers_id}'.\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "when creating routers with a name that already exists" do
    it "should fail" do
      cptr("routers:add #{@routers_name}")

      rsp = cptr("routers:add #{@routers_name} -g #{@network.name}")

      rsp.stderr.should eq("A router with the name '#{@routers_name}' already exists\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("routers:add #{@routers_name} -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
