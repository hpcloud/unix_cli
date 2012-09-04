require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:server command" do
  before(:all) do
    @srv1 = ServerTestHelper.create("srv1")
    @srv2 = ServerTestHelper.create("srv2")
    @vol1 = VolumeTestHelper.create("svl1")
    @vol1.attach(@srv1, '/dev/sdf')
    @vol2 = VolumeTestHelper.create("svl2")
    @vol2.attach(@srv2, '/dev/sdg')
    @vol3 = VolumeTestHelper.create("svl3")
    @vol3.attach(@srv1, '/dev/sdh')
    @vol1.fog.wait_for { in_use? }
    @vol2.fog.wait_for { in_use? }
    @vol3.fog.wait_for { in_use? }
  end

  context "when server volume with name" do
    it "should succeed" do
      rsp = cptr("volumes:server #{@srv1.name} #{@srv2.id}")

      rsp.stderr.should eq("")
      rsp.stdout.should include("| \e[1mname\e[0m | \e[1mserver\e[0m | \e[1mdevice\e[0m   |\n")

      rsp.stdout.should include("| svl1 | srv1   | /dev/sdf |\n")
      rsp.stdout.should include("| svl3 | srv1   | /dev/sdh |\n")
      rsp.stdout.should include("| svl2 | srv2   | /dev/sdg |\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:server with valid avl" do
    it "should be successful" do
      rsp = cptr("volumes:server #{@srv1.name} -z az-1.region-a.geo-1")

      rsp.stderr.should eq("")
      rsp.stdout.should include("| \e[1mname\e[0m | \e[1mserver\e[0m | \e[1mdevice\e[0m   |\n")
      rsp.stdout.should include("| svl1 | srv1   | /dev/sdf |\n")
      rsp.stdout.should include("| svl3 | srv1   | /dev/sdh |\n")
      rsp.exit_status.should be_exit(:success)
    end
  end

  context "volumes:server with invalid avl" do
    it "should report error" do
      rsp = cptr("volumes:server #{@srv1.name} -z blah")

      rsp.stderr.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
      rsp.stderr.should include("Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog.")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) { HP::Cloud::Connection.instance.clear_options() }
  end

  context "volumes:server with invalid volume" do
    it "should report error" do
      rsp = cptr("volumes:server bogus")

      rsp.stderr.should include("Cannot find a server matching 'bogus'.\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:not_found)
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:server bogus -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end
end
