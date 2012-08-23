require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'yaml'

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  context "set availability zone for compute service" do
    it "should set value" do
      rsp = cptr("config:set -s compute -z blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("The configuration setting(s) have been saved to the config file.\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for storage service" do
    it "should set value" do
      rsp = cptr("config:set -s storage -z blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("The configuration setting(s) have been saved to the config file.\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:storage_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for cdn service" do
    it "should set value" do
      rsp = cptr("config:set -s cdn -z blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("The configuration setting(s) have been saved to the config file.\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:cdn_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for block service" do
    it "should set value" do
      rsp = cptr("config:set -s block -z blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("The configuration setting(s) have been saved to the config file.\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:block_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for bogus service" do
    it "should set value" do
      rsp = cptr("config:set -s bogus -z blah2")
      rsp.stderr.should eql("The service name is not valid. The service name has to be one of these: storage, compute, cdn, block\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:not_supported)
    end
  end

  context "set availability zone with no zone passed in" do
    it "should set value" do
      rsp = cptr("config:set -s compute")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("The configuration setting(s) have been saved to the config file.\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should be_nil
    end
  end
end
