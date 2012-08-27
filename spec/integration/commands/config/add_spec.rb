require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')
require 'yaml'

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  context "set availability zone for compute service" do
    it "should set value" do
      rsp = cptr("config:set compute_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set compute_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for storage service" do
    it "should set value" do
      rsp = cptr("config:set storage_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set storage_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:storage_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for cdn service" do
    it "should set value" do
      rsp = cptr("config:set cdn_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set cdn_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:cdn_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for block service" do
    it "should set value" do
      rsp = cptr("config:set block_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set block_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:block_availability_zone).should eql("blah2")
    end
  end

  context "set availability zone for bogus service" do
    it "should set value" do
      rsp = cptr("config:set bogus_availability_zone=blah2")
      rsp.stderr.should eql("Unknown configuration key value 'bogus_availability_zone'\n")
      rsp.stdout.should eql("")
      rsp.exit_status.should be_exit(:general_error)
    end
  end

  context "set availability zone with no zone passed in" do
    it "should set value" do
      rsp = cptr("config:set compute_availability_zone=")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set compute_availability_zone=\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should be_nil
    end
  end

  context "set using add alias" do
    it "should set value" do
      rsp = cptr("config:add compute_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set compute_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should eql("blah2")
    end
  end

  context "set using update alias" do
    it "should set value" do
      rsp = cptr("config:update compute_availability_zone=blah2")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set compute_availability_zone=blah2\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:compute_availability_zone).should eql("blah2")
    end
  end

  context "set everything" do
    it "should set value" do
      rsp = cptr("config:update default_auth_uri=1 block_availability_zone=2 storage_availability_zone=3 compute_availability_zone=4 cdn_availability_zone=5 connect_timeout=6 read_timeout=7 write_timeout=8 ssl_verify_peer=9 ssl_ca_path=10 ssl_ca_file=11")
      rsp.stderr.should eql("")
      rsp.stdout.should eql("Configuration set default_auth_uri=1 block_availability_zone=2 storage_availability_zone=3 compute_availability_zone=4 cdn_availability_zone=5 connect_timeout=6 read_timeout=7 write_timeout=8 ssl_verify_peer=9 ssl_ca_path=10 ssl_ca_file=11\n")
      rsp.exit_status.should be_exit(:success)
      ConfigHelper.value(:default_auth_uri).should eq("1")
      ConfigHelper.value(:block_availability_zone).should eq("2")
      ConfigHelper.value(:storage_availability_zone).should eq("3")
      ConfigHelper.value(:compute_availability_zone).should eq("4")
      ConfigHelper.value(:cdn_availability_zone).should eq("5")
      ConfigHelper.value(:connect_timeout).should eq("6")
      ConfigHelper.value(:read_timeout).should eq("7")
      ConfigHelper.value(:write_timeout).should eq("8")
      ConfigHelper.value(:ssl_verify_peer).should eq("9")
      ConfigHelper.value(:ssl_ca_path).should eq("10")
      ConfigHelper.value(:ssl_ca_file).should eq("11")
    end
  end
end
