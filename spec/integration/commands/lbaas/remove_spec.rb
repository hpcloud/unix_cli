require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lbaass:remove command" do
  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Lbaass.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting lbaas with name" do
    it "should succeed" do
      @lbaas = LbaasTestHelper.create(resource_name("del1"))

      rsp = cptr("lbaass:remove #{@lbaas.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed lbaas '#{@lbaas.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lbaas.id)
    end
  end

  context "lbaass:remove with valid avl" do
    it "should be successful" do
      @lbaas = LbaasTestHelper.create(resource_name("del2"))

      rsp = cptr("lbaass:remove #{@lbaas.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed lbaas '#{@lbaas.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lbaas.id)
    end
  end

  context "lbaass:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("lbaass:remove lbaas_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      HP::Cloud::Connection.instance.clear_options()
      begin
        @lbaas.destroy
      rescue Exception => e
      end
    end
  end

  context "lbaass:remove with invalid lbaas" do
    it "should report error" do
      rsp = cptr("lbaass:remove bogus")

      rsp.stderr.should eq("Cannot find a lbaas matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lbaass:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
