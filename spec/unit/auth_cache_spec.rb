# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
      authcaches.read({}).should be_nil
    end
  end

  context "when something exists" do
    it "should provide credentials" do
      something = { :hp_access_key => 'a', :hp_tenant_id => 'b' }
      somethingelse = { :hp_access_key => 'c', :hp_tenant_id => 'd' }
      authcaches = AuthCache.new()
      creds = { :a => 'a', :b => 'b' }
      authcaches.write(something, creds)
      authcaches.write(somethingelse, nil)

      authcaches.read(somethingelse).should be_nil
      authcaches.read(something).should eq(creds)
      authcaches = AuthCache.new()
      authcaches.read(something).should eq(creds)
      authcaches.read(somethingelse).should be_nil
    end
  end

  context "when something else" do
    it "should provide credentials" do
      something = { :hp_access_key => 'a', :hp_tenant_id => 'b' }
      authcaches = AuthCache.new()
      authcaches.write(something, {:a => 'block'})

      authcaches.read(something)[:a].should eq('block')
    end
  end

  context "when removing" do
    it "should remove credentials" do
      something = { :hp_access_key => 'a', :hp_tenant_id => 'b' }
      another = { :hp_access_key => 'c', :hp_tenant_id => 'd' }
      onemore = { :hp_access_key => 'e', :hp_tenant_id => 'f' }
      yetanother = { :hp_access_key => 'g', :hp_tenant_id => 'h' }
      authcaches = AuthCache.new()
      authcaches.write(something, {:a => 'block'})
      authcaches.write(another, {:a => 'cdn'})
      authcaches.write(onemore, {:a => 'compute'})
      authcaches.write(yetanother, {:a => 'storage'})

      authcaches = AuthCache.new()
      authcaches.read(something)[:a].should eq('block')
      authcaches.read(another)[:a].should eq('cdn')
      authcaches.read(onemore)[:a].should eq('compute')
      authcaches.read(yetanother)[:a].should eq('storage')

      authcaches.remove(yetanother)

      authcaches = AuthCache.new()
      authcaches.read(something)[:a].should eq('block')
      authcaches.read(another)[:a].should eq('cdn')
      authcaches.read(onemore)[:a].should eq('compute')
      authcaches.read(yetanother).should be_nil

      authcaches.remove

      authcaches = AuthCache.new()
      authcaches.read(something).should be_nil
      authcaches.read(another).should be_nil
      authcaches.read(onemore).should be_nil
      authcaches.read(yetanother).should be_nil
    end
  end

  context "when something else" do
    it "should provide credentials" do
      something = { :hp_access_key => 'a', :hp_tenant_id => 'b' }
      bogus = { :hp_access_key => 'c', :hp_tenant_id => 'd' }
      authcaches = AuthCache.new()
      authcaches.write(something, {:service_catalog => {:DNS =>
        {:"region-a.geo-1" => "https://region-a.geo-1.dns.hpcloudsvc.com/v1/",
         :"region-b.geo-1" => "https://region-b.geo-1.dns.hpcloudsvc.com/v1/"}}})

      authcaches.default_zone(something, 'DNS').should eq('region-a.geo-1')
      authcaches.default_zone(bogus, 'DNS').should be_nil
      authcaches.default_zone(something, 'bogus').should be_nil
    end
  end

  context "create file name" do
    it "should make name" do
      opts = { :hp_access_key => 'a', :hp_tenant_id => 'b' }
      authcaches = AuthCache.new()
      authcaches.get_name(opts).should eq("a:b")
    end
  end

  after(:all) {reset_all()}
end
