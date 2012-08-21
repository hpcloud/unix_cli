require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'
include HP::Cloud

describe "Config directory naming" do
  before(:all) { HP::Cloud::Config.reset_home_directory() }
  
  it "should assemble properly" do
    HP::Cloud::Config.config_directory.should eql(ENV['HOME'] + '/.hpcloud/')
  end
  
  it "should include final slash" do
    HP::Cloud::Config.config_directory[-1,1].should eql('/')
  end
end

describe "Config directory setup" do
  
  before(:all) {
    AccountsHelper.use_fixtures()
  } 

  context "with no config directory present" do
    
    context "running ensure config" do
      
      before(:all) { HP::Cloud::Config.ensure_config_exists }
      
      it "should create base config directory" do
        File.directory?(HP::Cloud::Config.config_directory).should be_true
      end
      
      it "should create default config file" do
        File.exists?(HP::Cloud::Config.config_directory + 'config.yml').should be_true
      end
      
      it "should populate config file" do
        yaml = YAML::load(File.open(HP::Cloud::Config.config_file))
        yaml[:default_auth_uri].should eql("https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/")
        yaml[:compute_availability_zone].should eql("az-1.region-a.geo-1")
        yaml[:storage_availability_zone].should eql("region-a.geo-1")
        yaml[:cdn_availability_zone].should eql("region-a.geo-1")
      end
      
    end
    
  end
  
end

describe "Getting settings" do
  
  context "with no config file present" do
    
    before(:all) do
      HP::Cloud::Config.flush_settings
    end
    
    it "should return default auth uri" do
      HP::Cloud::Config.settings[:default_auth_uri].should eql('https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
    end
    it "should return availability zone for compute service" do
      HP::Cloud::Config.settings[:compute_availability_zone].should eql('az-1.region-a.geo-1')
    end
    it "should return availability zone for storage service" do
      HP::Cloud::Config.settings[:storage_availability_zone].should eql('region-a.geo-1')
    end
    it "should return availability zone for cdn service" do
      HP::Cloud::Config.settings[:cdn_availability_zone].should eql('region-a.geo-1')
    end

  end
  
  context "with config file present" do
    
    before(:all) do
      AccountsHelper.use_fixtures()
      HP::Cloud::Config.ensure_config_exists
      File.open(HP::Cloud::Config.config_file, 'w') do |file|
        file.write(read_fixture(:config, 'personalized.yml'))
      end
      HP::Cloud::Config.flush_settings
    end
    
    it "should return default auth uri" do
      HP::Cloud::Config.settings[:default_auth_uri].should eql('https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/')
    end
    it "should return availability zone for compute service" do
      HP::Cloud::Config.settings[:compute_availability_zone].should eql('az-1.region-a.geo-1')
    end
    it "should return availability zone for storage service" do
      HP::Cloud::Config.settings[:storage_availability_zone].should eql('region-a.geo-1')
    end
    it "should return availability zone for cdn service" do
      HP::Cloud::Config.settings[:cdn_availability_zone].should eql('region-a.geo-1')
    end

  end
  
end
