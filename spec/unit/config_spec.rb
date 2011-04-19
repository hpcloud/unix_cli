require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'

describe "Config directory naming" do
  it "should assemble properly" do
    HP::Scalene::Config.config_directory.should eql(ENV['HOME'] + '/.scalene/')
  end
  
  it "should include final slash" do
    HP::Scalene::Config.config_directory[-1,1].should eql('/')
  end
end

describe "Accounts directory naming" do
  it "should assemble properly" do
    HP::Scalene::Config.accounts_directory.should eql(ENV['HOME'] + '/.scalene/accounts/')
  end
  
  it "should include final slash" do
    HP::Scalene::Config.accounts_directory[-1,1].should eql('/')
  end
end

describe "Config directory setup" do
  
  before(:all) { setup_temp_home_directory } 

  context "with no config directory present" do
    
    before(:all) do
      FileUtils.rm_rf(HP::Scalene::Config.config_directory)
    end
    
    context "running ensure config" do
      
      before(:all) { HP::Scalene::Config.ensure_config_exists }
      
      it "should create base config directory" do
        Dir.exists?(HP::Scalene::Config.config_directory).should be_true
      end
      
      it "should create accounts directory" do
        Dir.exists?(HP::Scalene::Config.accounts_directory).should be_true
      end
      
      it "should create default config file" do
        File.exists?(HP::Scalene::Config.config_directory + 'config.yml').should be_true
      end
      
      it "should populate config file" do
        yaml = YAML::load(File.open(HP::Scalene::Config.config_file))
        yaml[:default_port].should eql('9232')
      end
      
    end
    
  end
  
end

describe "Writing an account file" do
  
  before(:all) do
    setup_temp_home_directory
    HP::Scalene::Config.ensure_config_exists
  end
  
  context "when account does not exist yet" do
    
    context "(default account)" do

      before(:all) do
        credentials = {:email => 'test@test.com', :account_id => '1234', :secret_key => 'foo'}
        HP::Scalene::Config.write_account(:default, credentials)
      end

      it "should create a file using account name" do
        File.exists?(HP::Scalene::Config.accounts_directory + 'default')
      end
      
      it "should have nested credentials" do
        yaml = YAML::load(File.open(HP::Scalene::Config.accounts_directory + 'default'))
        yaml.should have_key(:credentials)
      end
      
      it "should have written credential fields" do
        yaml = YAML::load(File.open(HP::Scalene::Config.accounts_directory + 'default'))
        yaml[:credentials][:email].should eql('test@test.com')
        yaml[:credentials][:account_id].should eql('1234')
        yaml[:credentials][:secret_key].should eql('foo')
      end

    end
    
  end
  
end

describe "Credential detection" do
  
  before(:all) do
    setup_temp_home_directory
    HP::Scalene::Config.ensure_config_exists
  end
  
  context "when default account exists" do
    
    before(:all) do
      File.open(HP::Scalene::Config.accounts_directory + "default", 'w') do |file|
        file.write(read_account_file('default'))
      end
    end
    
    #it "should detect default account file"
    
    it "should provide credentials from file" do
      credentials = HP::Scalene::Config.current_credentials
      credentials[:email].should eql('test@test.com')
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
      FileUtils.rm_rf(HP::Scalene::Config.config_directory)
      HP::Scalene::Config.flush_settings
    end
    
    it "should return default settings" do
      HP::Scalene::Config.settings[:default_port].should eql('9232')
    end
    
  end
  
  context "with config file present" do
    
    before(:all) do
      setup_temp_home_directory
      HP::Scalene::Config.ensure_config_exists
      File.open(HP::Scalene::Config.config_file, 'w') do |file|
        file.write(read_fixture(:config, 'personalized.yml'))
      end
      HP::Scalene::Config.flush_settings
    end
    
    it "should return specified settings" do
      HP::Scalene::Config.settings[:default_port].should eql('1234')
    end
    
  end
  
end

private

def setup_temp_home_directory
  HP::Scalene::Config.home_directory = File.expand_path(File.dirname(__FILE__) + '/../tmp/home')
  Dir.mkdir(HP::Scalene::Config.home_directory) unless Dir.exists?(HP::Scalene::Config.home_directory)
end
