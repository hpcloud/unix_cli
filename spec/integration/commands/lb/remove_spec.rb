require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "lb:remove" do
  def wait_for_gone(name)
      gone = false
      (0..15).each do |i|
        begin
          HP::Cloud::Lbs.new.get(name)
        rescue HP::Cloud::Exceptions::NotFound => e
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting lb with name" do
    it "should succeed" do
      @lb_name = "clidel1"
      cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.10.2.1,80")

      rsp = cptr("lb:remove #{@lb_name}")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed load balancer '#{@lb_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lb_name)
    end
  end

  context "lb:remove with valid avl" do
    it "should be successful" do
      @lb_name = "clidel2"
      cptr("lb:add #{@lb_name} ROUND_ROBIN HTTP 80 -n 10.10.2.2,80")

      rsp = cptr("lb:remove #{@lb_name} -z region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should eq("Removed load balancer '#{@lb_name}'.\n")
      rsp.exit_status.should be_exit(:success)
      wait_for_gone(@lb_name)
    end
  end

  context "lb:remove with invalid avl" do
    it "should report error" do
      rsp = cptr("lb:remove lb_name -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Load Balancer' service is activated for the appropriate availability zone.\n")
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

  context "lb:remove not found" do
    it "should report error" do
      rsp = cptr("lb:remove bogus")

      rsp.stderr.should eq("Cannot find a load balancer matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("lb:remove bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
