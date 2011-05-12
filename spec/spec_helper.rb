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
  KVS_ACCESS_ID = 'd00605fe9bddb1bf8d18d1a2ce35a2f437b200b8'
  KVS_SECRET_KEY = '2123c1444cb9e6263c2b049a897db970f96346bd'
  KVS_ACCOUNT_ID = '736985540040'
  KVS_HOST = '16.49.184.32'
  KVS_PORT = '9242'

end

