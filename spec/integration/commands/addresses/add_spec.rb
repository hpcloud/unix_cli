require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "addresses:add command" do
  def cli
    @cli ||= HP::Cloud::CLI.new
  end

  before(:all) do
    @hp_svc = compute_connection
  end

  context "when creating address" do
    it "should show success message" do
      rsp = cptr('addresses:add')

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created a public IP address")
      rsp.exit_status.should be_exit(:success)
      @public_ip = @response.scan(/'([^']+)/)[0][0]
      addresses = @hp_svc.addresses.map {|a| a.ip}
      addresses.should include(@public_ip)
    end

    after(:all) do
      address = get_address(@hp_svc, @public_ip)
      address.destroy if address
    end
  end

  context "addresses:add with valid avl" do
    it "should report success" do
      rsp = cptr('addresses:add -z az-1.region-a.geo-1')

      rsp.stderr.should eq("")
      rsp.stdout.should include("Created a public IP address")
      rsp.exit_status.should be_exit(:success)
      address = get_address(@hp_svc, @public_ip)
      address.destroy if address
      @public_ip = response.scan(/'([^']+)/)[0][0]
    end
  end

  context "addresses:add with invalid avl" do
    it "should report error" do
      rsp = cptr('addresses:add -z blah')

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { Connection.instance.clear_options() }
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("addresses:add -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
