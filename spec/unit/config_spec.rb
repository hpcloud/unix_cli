require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'
include HP::Cloud

describe "Config directory naming" do
  before(:each) { HP::Cloud::Config.home_directory = nil }
  it "should assemble properly" do
    config = HP::Cloud::Config.new()
    config.directory.should eq(ENV['HOME'] + '/.hpcloud/')
    config.file.should eq(ENV['HOME'] + '/.hpcloud/config.yml')
  end
end

describe "Config reading" do
  context "with no config file present" do
    before(:each) do
      ConfigHelper.use_tmp()
    end
    
    it "should have settings" do
      config = HP::Cloud::Config.new
      config.settings[:default_auth_uri].should eq('https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
      config.settings[:block_availability_zone].should eq('az-1.region-a.geo-1')
      config.settings[:cdn_availability_zone].should eq('region-a.geo-1')
      config.settings[:compute_availability_zone].should eq('az-1.region-a.geo-1')
      config.settings[:storage_availability_zone].should eq('region-a.geo-1')
      config.settings[:connect_timeout].should eq(30)
      config.settings[:read_timeout].should eq(30)
      config.settings[:write_timeout].should eq(30)
      config.settings[:ssl_verify_peer].should be_false
      config.settings[:ssl_ca_path].should be_nil
      config.settings[:ssl_ca_file].should be_nil
    end

    after(:each) do
      ConfigHelper.reset()
    end
  end
  
  context "with config file present" do
    before(:each) do
      ConfigHelper.use_fixtures()
    end
    
    it "should have settings" do
      config = HP::Cloud::Config.new
      config.settings[:default_auth_uri].should eq('https://127.0.0.1:35357/v2.0/')
      config.settings[:block_availability_zone].should eq('az-1.region-z.geo-1')
      config.settings[:cdn_availability_zone].should eq('region-z.geo-1')
      config.settings[:compute_availability_zone].should eq('az-1.region-z.geo-1')
      config.settings[:storage_availability_zone].should eq('region-z.geo-1')
      config.settings[:connect_timeout].should eq(35)
      config.settings[:read_timeout].should eq(40)
      config.settings[:write_timeout].should eq(45)
      config.settings[:ssl_verify_peer].should be_true
      config.settings[:ssl_ca_path].should eq('capath')
      config.settings[:ssl_ca_file].should eq('cafile')
    end
  end
  
  context "with bad configuration" do
    before(:each) do
      ConfigHelper.use_tmp()
      config = HP::Cloud::Config.new
      Dir.mkdir(config.directory) 
      File.open("#{config.file}", 'w') do |file|
        file.write "garbage"
      end
    end
    
    it "should raise error" do
      directory = ConfigHelper.tmp_directory
      lambda {
        config = HP::Cloud::Config.new
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Error reading configuration file: #{directory}/.hpcloud/config.yml")
      }
    end

    after(:each) do
      ConfigHelper.reset()
    end
  end
end
