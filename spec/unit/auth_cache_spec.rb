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
      authcaches.get_block('nothing').should be_nil
      authcaches.get_cdn('nothing').should be_nil
      authcaches.get_compute('nothing').should be_nil
      authcaches.get_storage('nothing').should be_nil
    end
  end

  context "when something exists" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      creds = { :a => 'a', :b => 'b' }
      authcaches.set_storage('something', creds)

      authcaches.get_block('something').should be_nil
      authcaches.get_cdn('something').should be_nil
      authcaches.get_compute('something').should be_nil
      authcaches.get_storage('something').should eq(creds)
    end
  end

  context "when something else" do
    it "should provide credentials" do
      authcaches = AuthCache.new()
      authcaches.set_block('something', {:a => 'block'})
      authcaches.set_cdn('something', {:a => 'cdn'})
      authcaches.set_compute('something', {:a => 'compute'})
      authcaches.set_storage('something', {:a => 'storage'})

      authcaches.get_block('something')[:a].should eq('block')
      authcaches.get_cdn('something')[:a].should eq('cdn')
      authcaches.get_compute('something')[:a].should eq('compute')
      authcaches.get_storage('something')[:a].should eq('storage')
    end
  end

  context "when removing" do
    it "should remove credentials" do
      authcaches = AuthCache.new()
      authcaches.set_block('something', {:a => 'block'})
      authcaches.set_cdn('another', {:a => 'cdn'})
      authcaches.set_compute('onemore', {:a => 'compute'})
      authcaches.set_storage('yetanother', {:a => 'storage'})

      authcaches = AuthCache.new()
      authcaches.get_block('something')[:a].should eq('block')
      authcaches.get_cdn('another')[:a].should eq('cdn')
      authcaches.get_compute('onemore')[:a].should eq('compute')
      authcaches.get_storage('yetanother')[:a].should eq('storage')

      authcaches.remove('yetanother')

      authcaches = AuthCache.new()
      authcaches.get_block('something')[:a].should eq('block')
      authcaches.get_cdn('another')[:a].should eq('cdn')
      authcaches.get_compute('onemore')[:a].should eq('compute')
      authcaches.get_storage('yetanother').should be_nil

      authcaches.remove

      authcaches = AuthCache.new()
      authcaches.get_block('something').should be_nil
      authcaches.get_cdn('another').should be_nil
      authcaches.get_compute('onemore').should be_nil
      authcaches.get_storage('yetanother').should be_nil
    end
  end

  after(:all) {reset_all()}
end
