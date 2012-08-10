require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:server command" do
  before(:all) do
    @srv1 = ServerTestHelper.create("srv1")
    @srv2 = ServerTestHelper.create("srv2")
    @vol1 = VolumeTestHelper.create("svl1")
    @vol1.attach(@srv1, '/dev/sdf').should be_true
    @vol2 = VolumeTestHelper.create("svl2")
    @vol2.attach(@srv2, '/dev/sdg').should be_true
    @vol3 = VolumeTestHelper.create("svl3")
    @vol3.attach(@srv1, '/dev/sdh').should be_true
    @vol1.fog.wait_for { in_use? }
    @vol2.fog.wait_for { in_use? }
    @vol3.fog.wait_for { in_use? }
  end

  context "when server volume with name" do
    before(:all) do
      @response, @exit = run_command("volumes:server #{@srv1.name} #{@srv2.id}").stdout_and_exit_status
    end

    it "should succeed" do
      @response.should include("| \e[1mname\e[0m | \e[1mserver\e[0m | \e[1mdevice\e[0m   |\n")
      @response.should include("| svl1 | srv1   | /dev/sdf |\n")
      @response.should include("| svl3 | srv1   | /dev/sdh |\n")
      @response.should include("| svl2 | srv2   | /dev/sdg |\n")
      @exit.should be_exit(:success)
    end
  end

  describe "with avl settings passed in" do
    context "volumes:server with valid avl" do
      before(:all) do
        @response, @exit = run_command("volumes:server #{@srv1.name} -z az-1.region-a.geo-1").stdout_and_exit_status
      end

      it "should be successful" do
        @response.should include("| \e[1mname\e[0m | \e[1mserver\e[0m | \e[1mdevice\e[0m   |\n")
        @response.should include("| svl1 | srv1   | /dev/sdf |\n")
        @response.should include("| svl3 | srv1   | /dev/sdh |\n")
      end
    end

    context "volumes:server with invalid avl" do
      it "should report error" do
        response, exit_status = run_command("volumes:server #{@srv1.name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'Compute' service is activated for the appropriate availability zone.\n")
        response.should include("Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog.")
        exit_status.should be_exit(:general_error)
      end
      after(:all) { HP::Cloud::Connection.instance.set_options({}) }
    end

    context "volumes:server with invalid volume" do
      it "should report error" do
        response, exit_status = run_command("volumes:server bogus").stderr_and_exit_status
        response.should include("Cannot find a server matching 'bogus'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
  end

  after(:all) do
#    begin
#      @vol1.destroy
#    rescue Exception => e
#    end
#    begin
#      @vol2.destroy
#    rescue Exception => e
#    end
#    begin
#      @vol3.destroy
#    rescue Exception => e
#    end
#    begin
#      @srv1.destroy
#    rescue Exception => e
#    end
  end
end
