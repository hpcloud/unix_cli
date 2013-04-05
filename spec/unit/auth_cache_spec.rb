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
      authcaches.get('nothing').should be_nil
    end
  end

  context "when something exists" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      creds = { :a => 'a', :b => 'b' }
      authcaches.set('something', creds)

      authcaches.get('something').should eq(creds)
      authcaches = AuthCache.new()
      authcaches.get('something').should eq(creds)
    end
  end

  context "when something else" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      authcaches.set('something', {:a => 'block'})

      authcaches.get('something')[:a].should eq('block')
    end
  end

  context "when removing" do
    it "should remove credentials" do
      authcaches = AuthCache.new()
      authcaches.set('something', {:a => 'block'})
      authcaches.set('another', {:a => 'cdn'})
      authcaches.set('onemore', {:a => 'compute'})
      authcaches.set('yetanother', {:a => 'storage'})

      authcaches = AuthCache.new()
      authcaches.get('something')[:a].should eq('block')
      authcaches.get('another')[:a].should eq('cdn')
      authcaches.get('onemore')[:a].should eq('compute')
      authcaches.get('yetanother')[:a].should eq('storage')

      authcaches.remove('yetanother')

      authcaches = AuthCache.new()
      authcaches.get('something')[:a].should eq('block')
      authcaches.get('another')[:a].should eq('cdn')
      authcaches.get('onemore')[:a].should eq('compute')
      authcaches.get('yetanother').should be_nil

      authcaches.remove

      authcaches = AuthCache.new()
      authcaches.get('something').should be_nil
      authcaches.get('another').should be_nil
      authcaches.get('onemore').should be_nil
      authcaches.get('yetanother').should be_nil
    end
  end

  after(:all) {reset_all()}
end
