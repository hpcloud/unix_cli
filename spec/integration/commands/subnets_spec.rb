require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Subnets command" do
  def then_expected_table(response)
    response.should match("#{@subnet1.name},")
    response.should match("#{@subnet2.name},")
  end

  before(:all) do
    @subnet1 = SubnetTestHelper.create("cli_test_subnet1")
    @subnet2= SubnetTestHelper.create("cli_test_subnet2")
  end

  context "subnets" do
    it "should report success" do
      rsp = cptr("subnets -d , #{@subnet1.name} #{@subnet2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "subnets:list" do
    it "should report success" do
      rsp = cptr("subnets:list -d , #{@subnet1.name} #{@subnet2.name}")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "subnets with valid avl" do
    it "should report success" do
      rsp = cptr("subnets -d , #{@subnet1.name} #{@subnet2.name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      then_expected_table(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "subnets with invalid avl" do
    it "should report error" do
      rsp = cptr('subnets -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Subnet' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("subnets -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
