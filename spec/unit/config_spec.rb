require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'

describe "Config directory naming" do
  before(:all) { reset_config_home_directory }
  
  it "should assemble properly" do
    HP::Cloud::Config.config_directory.should eql(ENV['HOME'] + '/.hpcloud/')
  end
  
  it "should include final slash" do
    HP::Cloud::Config.config_directory[-1,1].should eql('/')
  end
end

describe "Accounts directory naming" do
  before(:all) { reset_config_home_directory }
  
  it "should assemble properly" do
    HP::Cloud::Config.accounts_directory.should eql(ENV['HOME'] + '/.hpcloud/accounts/')
  end
  
  it "should include final slash" do
    HP::Cloud::Config.accounts_directory[-1,1].should eql('/')
  end
end

describe "Config directory setup" do
  
  before(:all) { setup_temp_home_directory } 

  context "with no config directory present" do
    
    before(:all) { remove_config_directory } 
    
    context "running ensure config" do
      
      before(:all) { HP::Cloud::Config.ensure_config_exists }
      
      it "should create base config directory" do
        File.directory?(HP::Cloud::Config.config_directory).should be_true
      end
      
      it "should create accounts directory" do
        File.directory?(HP::Cloud::Config.accounts_directory).should be_true
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

describe "Writing an account file" do
  
  before(:all) do
    setup_temp_home_directory
    HP::Cloud::Config.ensure_config_exists
  end
  
  context "when account does not exist yet" do
    
    context "(default account)" do

      before(:all) do
        credentials = {:account_id => 'foo', :secret_key => 'bar', :auth_uri => 'http://192.168.1.1:8888/v2.0'}
        HP::Cloud::Config.write_account(:default, credentials)
      end

      it "should create a file using account name" do
        File.exists?(HP::Cloud::Config.accounts_directory + 'default')
      end
      
      it "should have nested credentials" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml.should have_key(:credentials)
      end

    end
    
  end
end

describe "Modifying an account file" do

  before(:all) do
    setup_temp_home_directory
    HP::Cloud::Config.ensure_config_exists
  end

  context "when default account exists" do

    context "and account credentials are modified" do
      before(:all) do
        # setup default account settings
        setup_account_file(:default)
      end
      it "should have updated the credential fields" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml[:credentials][:account_id].should eql('foo1')
        yaml[:credentials][:secret_key].should eql('bar1')
        yaml[:credentials][:auth_uri].should eql('http://192.168.1.1:9999/v2.0')
        yaml[:credentials][:tenant_id].should eql('222222')
      end
    end

  end
  
end

describe "Credential detection" do
  
  before(:all) do
    setup_temp_home_directory
    HP::Cloud::Config.ensure_config_exists
  end
  
  context "when default account exists" do
    
    before(:all) do
      File.open(HP::Cloud::Config.accounts_directory + "default", 'w') do |file|
        file.write(read_account_file('default'))
      end
    end
    
    #it "should detect default account file"

    it "should provide credentials for account from file" do
      credentials = HP::Cloud::Config.read_credentials
      credentials[:account_id].should eql('foo')
      credentials[:secret_key].should eql('bar')
      credentials[:auth_uri].should eql('http://192.168.1.1:8888/v2.0')
      credentials[:tenant_id].should eql('111111')
    end

  end
  
  context "when no account file exists" do
    
    before(:all) do
      # remove any existing account files
    end
    
  end
  
end

describe "Getting settings" do
  
  context "with no config file present" do
    
    before(:all) do
      remove_config_directory
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
      setup_temp_home_directory
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
