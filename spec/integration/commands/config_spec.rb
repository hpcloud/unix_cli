require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  DEFAULT_CONFIG = "default_auth_uri: https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/\nblock_availability_zone: az-1.region-a.geo-1\nstorage_availability_zone: region-a.geo-1\ncompute_availability_zone: az-1.region-a.geo-1\ncdn_availability_zone: region-a.geo-1\nconnect_timeout: 30\nread_timeout: 30\nwrite_timeout: 30\nssl_verify_peer: true\n"

  context "config" do
    it "should report success" do
      rsp = cptr('config')
      rsp.stderr.should eq("")
      rsp.stdout.should eq(DEFAULT_CONFIG)
      rsp.exit_status.should be_exit(:success)
    end
  end
  context "config:list" do
    it "should report success" do
      rsp = cptr('config:list')
      rsp.stderr.should eq("")
      rsp.stdout.should eq(DEFAULT_CONFIG)
      rsp.exit_status.should be_exit(:success)
    end
  end
  after(:all) {reset_all()}
end
