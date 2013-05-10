require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lbs:remove command" do
  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Lbs.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting lb with name" do
    it "should succeed" do
      @lb = LbTestHelper.create(resource_name("del1"))

      rsp = cptr("lbs:remove #{@lb.name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed lb '#{@lb.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lb.id)
    end
  end

  context "lbs:remove with valid avl" do
    it "should be successful" do
      @lb = LbTestHelper.create(resource_name("del2"))

      rsp = cptr("lbs:remove #{@lb.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed lb '#{@lb.name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lb.id)
    end
  end

  context "lbs:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("lbs:remove lb_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end

    after(:all) do
      HP::Cloud::Connection.instance.clear_options()
      begin
        @lb.destroy
      rescue Exception => e
      end
    end
  end

  context "lbs:remove with invalid lb" do
    it "should report error" do
      rsp = cptr("lbs:remove bogus")

      rsp.stderr.should eq("Cannot find a lb matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lbs:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
