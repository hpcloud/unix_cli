require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Config command" do
  before(:all) do
    ConfigHelper.use_tmp()
  end

  def default_config(contents)
    contents.should include("default_auth_uri: https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/")
    contents.should include("block_availability_zone: az-1.region-a.geo-1")
    contents.should include("storage_availability_zone: region-a.geo-1")
    contents.should include("compute_availability_zone: az-1.region-a.geo-1")
    contents.should include("cdn_availability_zone: region-a.geo-1")
    contents.should include("connect_timeout: 30")
    contents.should include("read_timeout: 30")
    contents.should include("write_timeout: 30")
    contents.should include("ssl_verify_peer: true")
  end

  context "config" do
    it "should report success" do
      rsp = cptr('config')
      rsp.stderr.should eq("")
      default_config(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end
  context "config:list" do
    it "should report success" do
      rsp = cptr('config:list')
      rsp.stderr.should eq("")
      default_config(rsp.stdout)
      rsp.exit_status.should be_exit(:success)
    end
  end
  after(:all) {reset_all()}
end
