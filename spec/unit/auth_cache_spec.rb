require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'
require 'yaml'

include HP::Cloud


describe "AuthCaches default directory" do
  it "should assemble properly" do
    AuthCache.new.directory.should eq(ENV['HOME'] + '/.hpcloud/accounts/.cache/')
  end
end

describe "AuthCaches getting credentials" do
  before(:all) do
    AuthCacheHelper.use_tmp()
  end

  context "when nothing exists" do
    it "should provide have nothing" do
      authcaches = AuthCache.new()
      authcaches.read('nothing').should be_nil
    end
  end

  context "when something exists" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      creds = { :a => 'a', :b => 'b' }
      authcaches.write('something', creds)
      authcaches.write('somethingelse', nil)

      authcaches.read('somethingelse').should be_nil
      authcaches.read('something').should eq(creds)
      authcaches = AuthCache.new()
      authcaches.read('something').should eq(creds)
      authcaches.read('somethingelse').should be_nil
    end
  end

  context "when something else" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      authcaches.write('something', {:a => 'block'})

      authcaches.read('something')[:a].should eq('block')
    end
  end

  context "when removing" do
    it "should remove credentials" do
      authcaches = AuthCache.new()
      authcaches.write('something', {:a => 'block'})
      authcaches.write('another', {:a => 'cdn'})
      authcaches.write('onemore', {:a => 'compute'})
      authcaches.write('yetanother', {:a => 'storage'})

      authcaches = AuthCache.new()
      authcaches.read('something')[:a].should eq('block')
      authcaches.read('another')[:a].should eq('cdn')
      authcaches.read('onemore')[:a].should eq('compute')
      authcaches.read('yetanother')[:a].should eq('storage')

      authcaches.remove('yetanother')

      authcaches = AuthCache.new()
      authcaches.read('something')[:a].should eq('block')
      authcaches.read('another')[:a].should eq('cdn')
      authcaches.read('onemore')[:a].should eq('compute')
      authcaches.read('yetanother').should be_nil

      authcaches.remove

      authcaches = AuthCache.new()
      authcaches.read('something').should be_nil
      authcaches.read('another').should be_nil
      authcaches.read('onemore').should be_nil
      authcaches.read('yetanother').should be_nil
    end
  end

  context "when something else" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      authcaches.write('something', {:service_catalog => {:DNS =>
        {:"region-a.geo-1" => "https://region-a.geo-1.dns.hpcloudsvc.com/v1/",
         :"region-b.geo-1" => "https://region-b.geo-1.dns.hpcloudsvc.com/v1/"}}})

      authcaches.default_zone('something', 'DNS').should eq('region-a.geo-1')
      authcaches.default_zone('bogus', 'DNS').should be_nil
      authcaches.default_zone('something', 'bogus').should be_nil
    end
  end

  after(:all) {reset_all()}
end
