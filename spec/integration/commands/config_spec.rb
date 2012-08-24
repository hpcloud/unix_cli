require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  DEFAULT_CONFIG = "---\n:default_auth_uri: https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/\n:block_availability_zone: az-1.region-a.geo-1\n:storage_availability_zone: region-a.geo-1\n:compute_availability_zone: az-1.region-a.geo-1\n:cdn_availability_zone: region-a.geo-1\n:connect_timeout: 30\n:read_timeout: 30\n:write_timeout: 30\n:ssl_verify_peer: false\n"

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
end
