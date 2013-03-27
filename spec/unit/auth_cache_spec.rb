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

  after(:all) {reset_all()}
end
