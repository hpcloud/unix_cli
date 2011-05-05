$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
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
  KVS_ACCESS_ID = '85449051cf697c675ac3077217f4df39aab00c45'
  KVS_SECRET_KEY = '7cdcc353822b28a61665139de935fae2a869c0f7'
  KVS_ACCOUNT_ID = '807902568678'
  KVS_HOST = '16.49.184.32'
  KVS_PORT = '9242'

end

