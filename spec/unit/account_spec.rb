require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'

include HP::Cloud


describe "Accounts default directory" do
  it "should assemble properly" do
    Accounts.new.directory.should eql(ENV['HOME'] + '/.hpcloud/accounts/')
  end
end

describe "Accounts getting credentials" do
  before(:each) do
    @fixtures = File.expand_path(File.dirname(__FILE__) + '/../fixtures/accounts') + '/'
  end

  context "when default account exists" do
    it "should provide credentials for account from file" do
      accounts = Accounts.new(@fixtures)
      acct = accounts.get()
      acct[:account_id].should eql('foo')
      acct[:secret_key].should eql('bar')
      acct[:auth_uri].should eql('http://192.168.1.1:8888/v2.0')
      acct[:tenant_id].should eql('111111')
    end
  end

  context "when alternate account exists" do
    it "should provide credentials for account from file" do
      accounts = Accounts.new(@fixtures)
      acct = accounts.get('pro')
      acct[:account_id].should eql('DrDog')
      acct[:secret_key].should eql('BeTheVoid')
      acct[:auth_uri].should eql('http://TurningTheCentury/')
      acct[:tenant_id].should eql('350')
    end
  end

  context "when unknown account" do
    it "should return raise exception" do
      accounts = Accounts.new(@fixtures)
      lambda {accounts.get('bogus')}.should raise_error(Exception) {|e|
        e.to_s.should eq("Could not find account file: #{@fixtures}bogus")
      }
    end
  end

  context "when bad account file" do
    it "should return raise exception" do
      accounts = Accounts.new(@fixtures)
      lambda {accounts.get('bad')}.should raise_error(Exception) {|e|
        e.to_s.should eq("Error reading account file: #{@fixtures}bad")
      }
    end
  end
end

describe "Accounts setting credentials" do
  before(:each) do
    @fixtures = File.expand_path(File.dirname(__FILE__) + '/../fixtures/accounts') + '/'
  end

  context "when existing account file" do
    it "should change the settings" do
      accounts = Accounts.new(@fixtures)

      accounts.set_credentials('pro', 'LisaHannigan', 'Passenger', 'http://ASail/', '336')

      acct = accounts.get('pro')
      acct[:account_id].should eql('LisaHannigan')
      acct[:secret_key].should eql('Passenger')
      acct[:auth_uri].should eql('http://ASail/')
      acct[:tenant_id].should eql('336')
    end
  end

  context "when new account" do
    it "should change the settings" do
      accounts = Accounts.new(@fixtures)

      accounts.set_credentials('noob', 'SleeperAgent', 'Celabrasion', 'http://ThatsMyBaby/', '335')

      acct = accounts.get('noob')
      acct[:account_id].should eql('SleeperAgent')
      acct[:secret_key].should eql('Celabrasion')
      acct[:auth_uri].should eql('http://ThatsMyBaby/')
      acct[:tenant_id].should eql('335')
    end
  end
end

describe "Account write" do
  before(:each) do
    @fixtures = File.expand_path(File.dirname(__FILE__) + '/../tmp/accounts') + '/'
    FileUtils.rm_rf(@fixtures)
    FileUtils.mkpath(@fixtures)
  end

  context "when new account file" do
    it "should change the settings" do
      accounts = Accounts.new(@fixtures)
      accounts.set_credentials('nub', 'FionaApple', 'IdlerWheel', 'http://Daredevil/', '328')

      accounts.write('nub')

      accounts = Accounts.new(@fixtures)
      acct = accounts.get('nub')
      acct[:account_id].should eql('FionaApple')
      acct[:secret_key].should eql('IdlerWheel')
      acct[:auth_uri].should eql('http://Daredevil/')
      acct[:tenant_id].should eql('328')
    end
  end

  context "when existing account file" do
    it "should change the settings" do
      accounts = Accounts.new(@fixtures)
      accounts.set_credentials('indy', 'Ceremony', 'Zoo', 'http://Quarantine/', '306')
      accounts.write('indy')
      accounts.set_credentials('indy', 'TheHives', 'LexHives', 'http://GoRightAhead/', '307')

      accounts.write('indy')

      accounts = Accounts.new(@fixtures)
      acct = accounts.get('indy')
      acct[:account_id].should eql('TheHives')
      acct[:secret_key].should eql('LexHives')
      acct[:auth_uri].should eql('http://GoRightAhead/')
      acct[:tenant_id].should eql('307')
    end
  end

  after(:all) do
    #FileUtils.rm_rf(@fixtures)
  end
end
