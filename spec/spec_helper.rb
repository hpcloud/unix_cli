$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

if ENV['SPEC_CODE_COVERAGE'] and RUBY_VERSION[2,1] == '9'
  puts "Using simplecov..."
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_group "Commands", "/lib/scalene/commands"
  end
end

require 'rspec'
require 'scalene'

require 'helpers/fixtures'
require 'helpers/connections'
require 'helpers/io'
require 'helpers/configs'
require 'helpers/buckets'

RSpec.configure do |config|
  
  # export KVS_TEST_HOST=16.49.184.31
  # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9233 "Unix CLI" "unix.cli@hp.com"
  #
  # http://16.49.184.32:9242/kvs/keygen.html
  KVS_ACCESS_ID = '0fe012e5db618a083e6386464718f1e4327a1918'
  KVS_SECRET_KEY = '11e36dbbcb2d9a17397d1df3f37f7f4e7275b39d'
  KVS_ACCOUNT_ID = '145197220011'
  KVS_HOST = '16.49.184.32'
  KVS_PORT = '9242'
  SEC_KVS_ACCESS_ID = '92adebfc85cfc2800ea7bea7ae16045c276c4ec2'
  SEC_KVS_SECRET_KEY = '682c572b82d86071919d86e6c12f43d067da92fb'
  SEC_KVS_ACCOUNT_ID = '529285467718'
end

