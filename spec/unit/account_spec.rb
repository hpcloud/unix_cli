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
      acct = accounts.read()
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

      accounts.set_credentials('pro', 'LisaHannigan', 'Passenger', 'http://ASail/', '336')

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

      accounts.set_credentials('noob', 'SleeperAgent', 'Celabrasion', 'http://ThatsMyBaby/', '335')

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
      accounts.set_credentials('nub', 'FionaApple', 'IdlerWheel', 'http://Daredevil/', '328')
      accounts.set_zones('nub', 'az-1.region-a.geo-1', 'region-b.geo-1', 'region-c.geo-1', 'az-1.region-d.geo-1')

      accounts.write('nub')

      accounts = Accounts.new()
      acct = accounts.read('nub')
      acct[:credentials][:account_id].should eq('FionaApple')
      acct[:credentials][:secret_key].should eq('IdlerWheel')
      acct[:credentials][:auth_uri].should eq('http://Daredevil/')
      acct[:credentials][:tenant_id].should eq('328')
      acct[:zones][:compute_availability_zone].should eq('az-1.region-a.geo-1')
      acct[:zones][:storage_availability_zone].should eq('region-b.geo-1')
      acct[:zones][:cdn_availability_zone].should eq('region-c.geo-1')
      acct[:zones][:block_availability_zone].should eq('az-1.region-d.geo-1')
    end
  end

  context "when existing account file" do
    it "should change the settings" do
      accounts = Accounts.new()
      accounts.set_credentials('indy', 'Ceremony', 'Zoo', 'http://Quarantine/', '306')
      accounts.write('indy')
      accounts.set_credentials('indy', 'TheHives', 'LexHives', 'http://GoRightAhead/', '307')

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

      acct = accounts.get()

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

describe "Accounts" do
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

describe "Accounts" do
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

describe "Accounts" do
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
      accounts.set('Hives', :bogus, "What").should be_false
      accounts.set('bogus', :ssl_ca_file, "O7").should be_false

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
    end
  end
  after(:all) {reset_all()}
end
