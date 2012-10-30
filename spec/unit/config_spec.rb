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
      config.settings[:ssl_verify_peer].should be_true
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

    after(:all) {reset_all()}
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
        e.to_s.should include("Error reading configuration file: #{directory}/.hpcloud/config.yml\n")
      }
    end

    after(:each) do
      ConfigHelper.reset()
    end
  end
end

describe "Config set and get" do
  before(:each) do
    ConfigHelper.use_tmp()
  end
    
  context "with good value" do
    it "should return value" do
      config = HP::Cloud::Config.new()
      config.set('connect_timeout', '99').should be_true
      config.get('connect_timeout').should eq('99')
      config.set('connect_timeout', '').should be_true
      config.get('connect_timeout').should be_nil
    end
  end

  context "with nil availability zones" do
    it "should raise exception" do
      config = HP::Cloud::Config.new()
      lambda {
        config.set("block_availability_zone", "")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("The value of 'block_availability_zone' may not be empty")
      }
      lambda {
        config.set("storage_availability_zone", "")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("The value of 'storage_availability_zone' may not be empty")
      }
      lambda {
        config.set("compute_availability_zone", "")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("The value of 'compute_availability_zone' may not be empty")
      }
      lambda {
        config.set("cdn_availability_zone", "")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("The value of 'cdn_availability_zone' may not be empty")
      }
    end
  end

  context "set bogus" do
    it "should throw exception" do
      config = HP::Cloud::Config.new()
      lambda {
        config.set("bogus", "99")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Unknown configuration key value 'bogus'")
      }
    end
  end

  after(:each) do
    ConfigHelper.reset()
  end
end

describe "Config write" do
  before(:each) do
    ConfigHelper.use_tmp()
    @config = HP::Cloud::Config.new
    @config.write()
  end

  context "set nothing" do
    it "should create empty file" do
      ConfigHelper.contents.should match("--- \\{\\}\n*")
    end
  end

  context "set something" do
    it "should have the value" do
      @config.set("connect_timeout", "44")
      @config.write()
      ConfigHelper.contents.should match("--- *\n:connect_timeout: ['\"]44['\"]\n")
    end
  end

  context "set everything" do
    it "should have the value" do
      @config.set('default_auth_uri', '1val')
      @config.set('block_availability_zone', '2val')
      @config.set('storage_availability_zone', '3val')
      @config.set('compute_availability_zone', '4val')
      @config.set('cdn_availability_zone', '5val')
      @config.set('connect_timeout', '6val')
      @config.set('read_timeout', '7val')
      @config.set('write_timeout', '8val')
      @config.set('ssl_verify_peer', '9val')
      @config.set('ssl_ca_path', '10val')
      @config.set("ssl_ca_file", "11val")
      @config.write()
      contents = ConfigHelper.contents
      contents.should include(":default_auth_uri: 1val\n")
      contents.should include(":block_availability_zone: 2val\n")
      contents.should include(":storage_availability_zone: 3val\n")
      contents.should include(":compute_availability_zone: 4val\n")
      contents.should include(":cdn_availability_zone: 5val\n")
      contents.should include(":connect_timeout: 6val\n")
      contents.should include(":read_timeout: 7val\n")
      contents.should include(":write_timeout: 8val\n")
      contents.should include(":ssl_verify_peer: true\n")
      contents.should include(":ssl_ca_path: 10val\n")
      contents.should include(":ssl_ca_file: 11val\n")
    end
  end


  context "set ssl_verify_peer" do
    it "should be boolean" do
      @config.set('ssl_verify_peer', 'yeh')
      @config.get('ssl_verify_peer').should eq(true)
      @config.write()
      @config = HP::Cloud::Config.new
      @config.get('ssl_verify_peer').should eq(true)

      @config.set('ssl_verify_peer', 'false')
      @config.get('ssl_verify_peer').should eq(false)
      @config.write()
      @config = HP::Cloud::Config.new
      @config.get('ssl_verify_peer').should eq(false)
    end
  end

  context "clear something" do
    it "should have the value" do
      @config.set("connect_timeout", "33")
      @config.write()
      ConfigHelper.contents.should match("--- *\n:connect_timeout: ['\"]33['\"]\n")
      @config.set("connect_timeout", "")
      @config.write()
      ConfigHelper.contents.should match("--- \\{\\}\n*")
    end
  end

  after(:each) do
    ConfigHelper.reset()
  end
end

describe "Config split nvp" do
  context "should split valid nvp" do
    it "should handle valid cases" do
      k, v = HP::Cloud::Config.split("abc=123")
      k.should eq("abc")
      v.should eq("123")
    end

    it "should handle nil cases" do
      k, v = HP::Cloud::Config.split("abc=")
      k.should eq("abc")
      v.should eq("")
    end
  end

  context "should throw exceptions on bad cases" do
    it "should handle no equal" do
      lambda {
        HP::Cloud::Config.split("abc")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Invalid name value pair: 'abc'")
      }
    end

    it "should handle too many equal" do
      lambda {
        HP::Cloud::Config.split("abc=123=22")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Invalid name value pair: 'abc=123=22'")
      }
    end

    it "should handle nothing" do
      lambda {
        HP::Cloud::Config.split("")
      }.should raise_error(Exception) {|e|
        e.to_s.should eq("Invalid name value pair: ''")
      }
    end
  end
end
