require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:detach command" do
  before(:all) do
    @server = ServerTestHelper.create("detach")
  end

  context "when detach volume with name" do
    before(:all) do
      @vol1 = VolumeTestHelper.create("one")
      @vol1.detach()
      @vol1.fog.wait_for { ready? }
      @vol1.attach(@server, '/dev/sdf').should be_true
      @vol1.fog.wait_for { in_use? }
      @response, @exit = run_command("volumes:detach #{@vol1.name}").stdout_and_exit_status
    end

    it "should succeed" do
      @response.should eql("Detached volume '#{@vol1.name}' from '#{@server.name}'.\n")
      @exit.should be_exit(:success)
    end

    after(:all) do
      begin
        @vol1.destroy
      rescue Exception => e
      end
    end
  end

  describe "with avl settings passed in" do

    context "volumes:detach with valid avl" do
      before(:all) do
        @vol2 = VolumeTestHelper.create("two")
        @vol2.detach()
        @vol2.fog.wait_for { ready? }
        @vol2.attach(@server, '/dev/sdg').should be_true
        @vol2.fog.wait_for { in_use? }
        @response, @exit = run_command("volumes:detach #{@vol2.name} -z az-1.region-a.geo-1").stdout_and_exit_status
      end

      it "should be successful" do
        @response.should eql("Detached volume '#{@vol2.name}' from '#{@server.name}'.\n")
        @exit.should be_exit(:success)
      end

      after(:all) do
        begin
          @vol2.destroy
        rescue Exception => e
        end
      end
    end

    context "volumes:detach with invalid avl" do

      it "should report error" do
        @vol3 = VolumeTestHelper.create("three")
        @vol3.detach()
        @vol3.fog.wait_for { ready? }
        @vol3.attach(@server, '/dev/sdh').should be_true
        @vol3.fog.wait_for { in_use? }
        response, exit_status = run_command("volumes:detach #{@vol3.name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
        response.should include("Exception: Unable to retrieve endpoint service url for availability zone 'blah' from service catalog.")
        exit_status.should be_exit(:general_error)
      end

      after(:all) do
        HP::Cloud::Connection.instance.clear_options()
        begin
          @vol3.destroy
        rescue Exception => e
        end
      end
    end

    context "volumes:detach with invalid volume" do
      it "should report error" do
        response, exit_status = run_command("volumes:detach bogus").stderr_and_exit_status
        response.should include("Cannot find a volume matching 'bogus'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
  end

  context "verify the -a option is activated" do
    it "should report error" do
      AccountsHelper.use_tmp()

      rsp = cptr("volumes:detach something -a bogus")

      tmpdir = AccountsHelper.tmp_dir()
      rsp.stderr.should eq("Could not find account file: #{tmpdir}/.hpcloud/accounts/bogus\n")
      rsp.stdout.should eq("")
      rsp.exit_status.should be_exit(:general_error)
    end
    after(:all) {reset_all()}
  end

  after(:all) do
    begin
      @server.destroy
    rescue Exception => e
    end
  end

end
