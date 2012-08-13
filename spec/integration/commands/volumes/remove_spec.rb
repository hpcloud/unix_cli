require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "volumes:remove command" do
  def wait_for_gone(id)
      gone = false
      (0..15).each do |i|
        if HP::Cloud::Volumes.new.get(id.to_s).is_valid? == false
          gone = true
          break
        end
        sleep(1)
      end
      gone.should be_true
  end

  context "when deleting volume with name" do
    before(:all) do
      @volume = VolumeTestHelper.create("one")
      @response, @exit = run_command("volumes:remove #{@volume.name}").stdout_and_exit_status
    end

    it "should succeed" do
      @response.should eql("Removed volume '#{@volume.name}'.\n")
      @exit.should be_exit(:success)
    end

    it "should go away" do
      wait_for_gone(@volume.id)
    end
  end

  describe "with avl settings passed in" do

    context "volumes:remove with valid avl" do
      before(:all) do
        @volume = VolumeTestHelper.create("two")
        @response, @exit = run_command("volumes:remove #{@volume.name} -z az-1.region-a.geo-1").stdout_and_exit_status
      end

      it "should be successful" do
        @response.should eql("Removed volume '#{@volume.name}'.\n")
        @exit.should be_exit(:success)
      end

      it "should go away" do
        wait_for_gone(@volume.id)
      end
    end

    context "volumes:remove with invalid avl" do
      before(:all) do
        @volume = VolumeTestHelper.create("three")
      end

      it "should report error" do
        response, exit_status = run_command("volumes:remove #{@volume.name} -z blah").stderr_and_exit_status
        response.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
        exit_status.should be_exit(:general_error)
      end

      after(:all) do
        HP::Cloud::Connection.instance.set_options({})
        begin
          @volume.destroy
        rescue Exception => e
        end
      end
    end

    context "volumes:remove with invalid volume" do
      it "should report error" do
        response, exit_status = run_command("volumes:remove bogus").stderr_and_exit_status
        response.should include("Cannot find a volume matching 'bogus'.\n")
        exit_status.should be_exit(:not_found)
      end
    end
  end

end
