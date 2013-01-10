require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'

include HP::Cloud


describe "Accounts default directory" do
  it "should assemble properly" do
    Accounts.new.directory.should eq(ENV['HOME'] + '/.hpcloud/accounts/')
  end
end

describe "Accounts getting credentials" do
  before(:all) do
    AccountsHelper.use_fixtures()
  end

  context "when default account exists" do
    it "should provide credentials for account from file" do
      accounts = Accounts.new()
      acct = accounts.read('hp')
      acct[:credentials][:account_id].should eq('foo')
      acct[:credentials][:secret_key].should eq('bar')
      acct[:credentials][:auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      acct[:credentials][:tenant_id].should eq('111111')
    end
  end

  context "when alternate account exists" do
    it "should provide credentials for account from file" do
      accounts = Accounts.new()
      acct = accounts.read('pro')
      acct[:credentials][:account_id].should eq('DrDog')
      acct[:credentials][:secret_key].should eq('BeTheVoid')
      acct[:credentials][:auth_uri].should eq('http://TurningTheCentury/')
      acct[:credentials][:tenant_id].should eq('350')
    end
  end

  context "when unknown account" do
    it "should return raise exception" do
      accounts = Accounts.new()
      lambda {accounts.read('bogus')}.should raise_error(Exception) {|e|
        e.to_s.should eq("Could not find account file: #{accounts.directory}bogus")
      }
    end
  end

  context "when bad account file" do
    it "should return raise exception" do
      accounts = Accounts.new()
      lambda {accounts.read('bad')}.should raise_error(Exception) {|e|
        e.to_s.should eq("Error reading account file: #{accounts.directory}bad")
      }
    end
  end
  after(:all) {reset_all()}
end

describe "Accounts setting credentials" do
  before(:each) do
    AccountsHelper.use_fixtures()
  end

  context "when existing account file" do
    it "should change the settings" do
      accounts = Accounts.new()
      cred = { :account_id => 'LisaHannigan',
               :secret_key => 'Passenger',
               :auth_uri => 'http://ASail/',
               :tenant_id => '336'
             }

      accounts.set_cred('pro', cred)

      acct = accounts.read('pro')
      acct[:credentials][:account_id].should eq('LisaHannigan')
      acct[:credentials][:secret_key].should eq('Passenger')
      acct[:credentials][:auth_uri].should eq('http://ASail/')
      acct[:credentials][:tenant_id].should eq('336')
    end
  end

  context "when new account" do
    it "should change the settings" do
      accounts = Accounts.new()
      cred = { :account_id => 'SleeperAgent',
               :secret_key => 'Celabrasion',
               :auth_uri => 'http://ThatsMyBaby/',
               :tenant_id => '335'
             }

      accounts.set_cred('noob', cred)

      acct = accounts.read('noob')
      acct[:credentials][:account_id].should eq('SleeperAgent')
      acct[:credentials][:secret_key].should eq('Celabrasion')
      acct[:credentials][:auth_uri].should eq('http://ThatsMyBaby/')
      acct[:credentials][:tenant_id].should eq('335')
    end
  end
  after(:all) {reset_all()}
end

describe "Account write" do
  before(:each) do
    AccountsHelper.use_tmp()
  end

  context "when there ain't nothin" do
    it "should report error" do
      AccountsHelper.use_tmp()
      accounts = Accounts.new()
      tmp_dir = AccountsHelper.tmp_dir + "/.hpcloud/accounts/"
      AccountsHelper.reset()
      accounts.list.should eq("No such file or directory - #{tmp_dir}\nRun account:setup to create accounts.")
    end
  end

  context "when new account file" do
    it "should change the settings" do
      accounts = Accounts.new()
      cred = { :account_id => 'FionaApple',
               :secret_key => 'IdlerWheel',
               :auth_uri => 'http://Daredevil/',
               :tenant_id => '328'
             }
      zones = { :compute_availability_zone => 'az-1.region-a.geo-1',
                :storage_availability_zone => 'region-b.geo-1',
                :block_availability_zone => 'az-1.region-d.geo-1'
              }
      accounts.set_cred('nub', cred)
      accounts.set_zones('nub', zones)

      accounts.write('nub')

      accounts = Accounts.new()
      acct = accounts.read('nub')
      acct[:credentials][:account_id].should eq('FionaApple')
      acct[:credentials][:secret_key].should eq('IdlerWheel')
      acct[:credentials][:auth_uri].should eq('http://Daredevil/')
      acct[:credentials][:tenant_id].should eq('328')
      acct[:zones][:compute_availability_zone].should eq('az-1.region-a.geo-1')
      acct[:zones][:storage_availability_zone].should eq('region-b.geo-1')
      acct[:zones][:cdn_availability_zone].should eq('region-a.geo-1')
      acct[:zones][:block_availability_zone].should eq('az-1.region-d.geo-1')
    end
  end

  context "when existing account file" do
    it "should change the settings" do
      accounts = Accounts.new()
      cred = { :account_id => 'Ceremony',
               :secret_key => 'Zoo',
               :auth_uri => 'http://Quarantine/',
               :tenant_id => '306'
             }
      accounts.set_cred('indy', cred)
      accounts.write('indy')
      cred = { :account_id => 'TheHives',
               :secret_key => 'LexHives',
               :auth_uri => 'http://GoRightAhead/',
               :tenant_id => '307'
             }
      accounts.set_cred('indy', cred)

      accounts.write('indy')

      accounts = Accounts.new()
      acct = accounts.read('indy')
      acct[:credentials][:account_id].should eq('TheHives')
      acct[:credentials][:secret_key].should eq('LexHives')
      acct[:credentials][:auth_uri].should eq('http://GoRightAhead/')
      acct[:credentials][:tenant_id].should eq('307')
    end
  end

  after(:each) do
    AccountsHelper.reset()
  end
end

describe "Account get" do
  before(:each) do
    AccountsHelper.use_fixtures()
    ConfigHelper.use_tmp()
  end

  context "when getting account" do
    it "should include full default settings settings" do
      accounts = Accounts.new()

      acct = accounts.get('hp')

      acct[:credentials][:account_id].should eq('foo')
      acct[:credentials][:secret_key].should eq('bar')
      acct[:credentials][:auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      acct[:credentials][:tenant_id].should eq('111111')
      acct[:zones][:compute_availability_zone].should eq('az-1.region-a.geo-1')
      acct[:zones][:storage_availability_zone].should eq('region-a.geo-1')
      acct[:zones][:cdn_availability_zone].should eq('region-a.geo-1')
      acct[:zones][:block_availability_zone].should eq('az-1.region-a.geo-1')
      acct[:options][:connect_timeout].should eq(30)
      acct[:options][:read_timeout].should eq(30)
      acct[:options][:write_timeout].should eq(30)
      acct[:options][:ssl_verify_peer].should be_true
      acct[:options][:ssl_ca_path].should be_nil
      acct[:options][:ssl_ca_file].should be_nil
    end
  end
  after(:all) {reset_all()}
end

describe "Accounts create" do
  before(:each) do
    AccountsHelper.use_fixtures()
  end

  context "when create called" do
    it "should have basic settings" do
      accounts = Accounts.new()
      acct = accounts.create('mumford')
      uri = HP::Cloud::Config.new.get(:default_auth_uri)

      acct[:credentials].should eq({:auth_uri=>uri})
      zones = {:compute_availability_zone=>"az-1.region-a.geo-1", :storage_availability_zone=>"region-a.geo-1", :cdn_availability_zone=>"region-a.geo-1", :block_availability_zone=>"az-1.region-a.geo-1"}
      acct[:zones].should eq(zones)
      acct[:options].should eq({})
    end
  end
  after(:all) {reset_all()}
end

describe "Accounts rejigger" do
  before(:each) do
    AccountsHelper.use_tmp()
  end

  context "when rejigger called" do
    it "should have basic settings" do
      accounts = Accounts.new()
      acct = accounts.create('Walkmen')
      acct[:zones][:compute_availability_zone] = "az-2.region-b.geo-1"

      accounts.rejigger_zones(acct[:zones])

      acct[:zones][:compute_availability_zone].should eq("az-2.region-b.geo-1")
      acct[:zones][:storage_availability_zone].should eq("region-b.geo-1")
      acct[:zones][:cdn_availability_zone].should eq("region-b.geo-1")
      acct[:zones][:block_availability_zone].should eq("az-2.region-b.geo-1")
    end
  end
  after(:all) {reset_all()}
end

describe "Accounts set" do
  before(:each) do
    AccountsHelper.use_tmp()
  end

  context "when we use set" do
    it "should set the right setting" do
      accounts = Accounts.new()
      accounts.create('Hives')
      accounts.set('Hives', :account_id, "C1").should be_true
      accounts.set('Hives', :secret_key, "C2").should be_true
      accounts.set('Hives', :auth_uri, "C3").should be_true
      accounts.set('Hives', :tenant_id, "C4").should be_true
      accounts.set('Hives', :compute_availability_zone, "Z1").should be_true
      accounts.set('Hives', :storage_availability_zone, "Z2").should be_true
      accounts.set('Hives', :cdn_availability_zone, "Z3").should be_true
      accounts.set('Hives', :block_availability_zone, "Z4").should be_true
      accounts.set('Hives', :connect_timeout, "1").should be_true
      accounts.set('Hives', :read_timeout, "2").should be_true
      accounts.set('Hives', :write_timeout, "3").should be_true
      accounts.set('Hives', :ssl_verify_peer, "O4").should be_true
      accounts.set('Hives', :ssl_ca_path, "O5").should be_true
      accounts.set('Hives', :ssl_ca_file, "O6").should be_true
      accounts.set('Hives', :preferred_flavor, "O8").should be_true
      accounts.set('Hives', :preferred_image, "O9").should be_true
      accounts.set('Hives', :bogus, "What").should be_false
      accounts.set('bogus', :ssl_ca_file, "10").should be_false

      acct = accounts.get('Hives')
      acct[:credentials][:account_id].should eq("C1")
      acct[:credentials][:secret_key].should eq("C2")
      acct[:credentials][:auth_uri].should eq("C3")
      acct[:credentials][:tenant_id].should eq("C4")
      acct[:zones][:compute_availability_zone].should eq("Z1")
      acct[:zones][:storage_availability_zone].should eq("Z2")
      acct[:zones][:cdn_availability_zone].should eq("Z3")
      acct[:zones][:block_availability_zone].should eq("Z4")
      acct[:options][:connect_timeout].should eq(1)
      acct[:options][:read_timeout].should eq(2)
      acct[:options][:write_timeout].should eq(3)
      acct[:options][:ssl_verify_peer].should eq(true)
      acct[:options][:ssl_ca_path].should eq("O5")
      acct[:options][:ssl_ca_file].should eq("O6")
      acct[:options][:preferred_flavor].should eq("O8")
      acct[:options][:preferred_image].should eq("O9")
    end
  end
  after(:all) {reset_all()}
end

describe "Accounts migrate" do
  before(:each) do
    AccountsHelper.use_tmp()
    ConfigHelper.use_tmp()
    config = HP::Cloud::Config.new(true)
    config.set(:default_account, 'default')
    config.write()
  end

  context "when we have nothing" do
    it "should do nothing" do
      accounts = Accounts.new()

      accounts.migrate.should be_false
    end
  end

  context "when we have default" do
    it "should migrate" do
      accounts = Accounts.new()
      acct = accounts.create('default')
      acct[:username] = 'default@example.com'
      accounts.write('default')

      accounts.migrate.should be_true

      accounts = Accounts.new()
      accounts.list.should eq("hp")
      acct = accounts.read('hp')
      acct[:username].should eq('default@example.com')
      config = HP::Cloud::Config.new(true)
      config.get(:default_account).should eq('hp')
    end
  end


  context "when we have default and hp" do
    it "should not migrate" do
      accounts = Accounts.new()
      acct = accounts.create('default')
      acct[:username] = 'default@example.com'
      accounts.write('default')
      hp = accounts.create('hp')
      hp[:username] = 'hp@example.com'
      accounts.write('hp')

      accounts.migrate.should be_false

    end
  end

  after(:all) {reset_all()}
end

describe "Connection options" do
  context "when we create" do
    before(:each) do
      AccountsHelper.use_fixtures()
      ConfigHelper.use_tmp()
      Connection.instance.set_options({})
    end

    def expected_options()
      eopts = HP::Cloud::Config.default_options.clone
      eopts.delete_if{ |k,v| v.nil? }
      eopts.delete(:preferred_flavor)
      eopts.delete(:default_account)
      eopts.delete(:checker_url)
      eopts.delete(:checker_deferment)
      return eopts
    end

    it "should have expected values with avail zone" do
      options = Accounts.new.create_options('hp', :storage_availability_zone, 'somethingelse')

      options[:provider].should eq('hp')
      options[:connection_options].should eq(expected_options)
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('somethingelse')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Accounts.new.create_options('hp', :compute_availability_zone)

      options[:provider].should eq('hp')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('az-1.region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Accounts.new.create_options('hp', :storage_availability_zone)

      options[:provider].should eq('hp')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Accounts.new.create_options('hp', :cdn_availability_zone)

      options[:provider].should eq('hp')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should have expected values" do
      options = Accounts.new.create_options('hp', :block_availability_zone)

      options[:provider].should eq('hp')
      options[:connection_options].should eq(expected_options())
      options[:hp_account_id].should eq('foo')
      options[:hp_secret_key].should eq('bar')
      options[:hp_auth_uri].should eq('http://192.168.1.1:8888/v2.0')
      options[:hp_tenant_id].should eq('111111')
      options[:hp_avl_zone].should eq('az-1.region-a.geo-1')
      options[:user_agent].should eq("HPCloud-UnixCLI/#{HP::Cloud::VERSION}")
    end

    it "should throw exception" do
      directory = Accounts.new.directory
      lambda {
        Accounts.new.create_options('bogus', :storage_availability_zone)
      }.should raise_error(Exception, "Could not find account file: #{directory}bogus")
    end
  end
  after(:all) {reset_all()}
end
