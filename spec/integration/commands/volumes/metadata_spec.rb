#require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
#require 'hpcloud/volume_helper'
#
#describe "Volumes command" do
#  before(:all) do
#    @vol = VolumeTestHelper.create("meta_vol")
#    @vol.meta.set_metadata('luke=skywalker,han=solo')
#  end
#
#  describe "with avl settings from config" do
#    context "volumes" do
#      it "should report success" do
#        response, exit_status = run_command("volumes:metadata #{@vol.id}").stdout_and_exit_status
#        exit_status.should be_exit(:success)
#        response.should include("luke")
#        response.should include("skywalker")
#        response.should include("han")
#        response.should include("solo")
#      end
#    end
#
#    context "volumes" do
#      it "should report success" do
#        response, exit_status = run_command("volumes:metadata #{@vol.name}").stdout_and_exit_status
#        exit_status.should be_exit(:success)
#        response.should include("luke")
#        response.should include("skywalker")
#        response.should include("han")
#        response.should include("solo")
#      end
#    end
#
#    context "volumes:metadata:list" do
#      it "should report success" do
#        response, exit_status = run_command("volumes:metadata:list #{@vol.id}").stdout_and_exit_status
#        exit_status.should be_exit(:success)
#      end
#    end
#  end
#
#  describe "with avl settings passed in" do
#    context "volumes with valid avl" do
#      it "should report success" do
#        response, exit_status = run_command("volumes:metadata:list -z az-1.region-a.geo-1 #{@vol.id}").stdout_and_exit_status
#        exit_status.should be_exit(:success)
#      end
#    end
#    context "volumes with invalid avl" do
#      it "should report error" do
#        response, exit_status = run_command("volumes:metadata -z blah #{@vol.id}").stderr_and_exit_status
#        response.should include("Please check your HP Cloud Services account to make sure the 'BlockStorage' service is activated for the appropriate availability zone.\n")
#        exit_status.should be_exit(:general_error)
#      end
#      after(:all) { HP::Cloud::Connection.instance.clear_options() }
#    end
#  end
#
#  after(:all) do
#    @vol.destroy() unless @vol.nil?
#  end
#end
