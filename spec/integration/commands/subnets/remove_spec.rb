require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "subnets:remove command" do
  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Subnets.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting subnet with name" do
    it "should succeed" do
      @subnet = SubnetTestHelper.create("127.0.1.1")

      rsp = cptr("subnets:remove #{@subnet.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed subnet '#{@subnet.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@subnet.id)
    end
  end

  context "subnets:remove with valid avl" do
    it "should be successful" do
      @subnet = SubnetTestHelper.create("127.0.2.1")

      rsp = cptr("subnets:remove #{@subnet.id} -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed subnet '#{@subnet.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@subnet.id)
    end
  end

  context "subnets:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("subnets:remove subnet_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Network' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      HP::Cloud::Connection.instance.clear_options()
      begin
        @subnet.destroy
      rescue Exception => e
      end
    end
  end

  context "subnets:remove with invalid subnet" do
    it "should report error" do
      rsp = cptr("subnets:remove bogus")

      rsp.stderr.should eq("Cannot find a subnet matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("subnets:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
