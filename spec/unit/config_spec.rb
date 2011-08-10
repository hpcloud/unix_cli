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
        yaml[:default_auth_uri].should eql("http://agpa-ge1.csbu.hpl.hp.com/auth/v1.0")
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
        credentials = {:storage => {:account_id => 'account:user', :secret_key => 'foo', :auth_uri => 'http://192.168.1.1:8888/auth/v1.0'},
                       :compute => {:account_id => 'user', :secret_key => 'bar', :auth_uri => 'http://192.168.1.1:8888/v1.0'}
                      }
        HP::Cloud::Config.write_account(:default, credentials)
      end

      it "should create a file using account name" do
        File.exists?(HP::Cloud::Config.accounts_directory + 'default')
      end
      
      it "should have nested credentials" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml.should have_key(:credentials)
      end
      it "should have nested credentials for storage" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml[:credentials].should have_key(:storage)
      end
      it "should have nested credentials for compute" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml[:credentials].should have_key(:compute)
      end

      it "should have written storage related credential fields" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml[:credentials][:storage][:account_id].should eql('account:user')
        yaml[:credentials][:storage][:secret_key].should eql('foo')
        yaml[:credentials][:storage][:auth_uri].should eql('http://192.168.1.1:8888/auth/v1.0')
      end
      it "should have written compute related credential fields" do
        yaml = YAML::load(File.open(HP::Cloud::Config.accounts_directory + 'default'))
        yaml[:credentials][:compute][:account_id].should eql('user')
        yaml[:credentials][:compute][:secret_key].should eql('bar')
        yaml[:credentials][:compute][:auth_uri].should eql('http://192.168.1.1:8888/v1.0')
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
    
    it "should provide credentials for storage from file" do
      credentials = HP::Cloud::Config.current_credentials
      credentials[:storage][:account_id].should eql('account:user')
      credentials[:storage][:secret_key].should eql('foo')
      credentials[:storage][:auth_uri].should eql('http://192.168.1.1:8888/auth/v1.0')
    end
    
    it "should provide credentials for compute from file" do
      credentials = HP::Cloud::Config.current_credentials
      credentials[:compute][:account_id].should eql('user')
      credentials[:compute][:secret_key].should eql('bar')
      credentials[:compute][:auth_uri].should eql('http://192.168.1.1:8888/v1.0')
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
    
    it "should return default settings" do
      HP::Cloud::Config.settings[:default_auth_uri].should eql('http://agpa-ge1.csbu.hpl.hp.com/auth/v1.0')
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
    
    it "should return specified settings" do
      HP::Cloud::Config.settings[:auth_uri].should eql('http://agpa-ge1.csbu.hpl.hp.com/auth/v1.0')
    end
    
  end
  
end
