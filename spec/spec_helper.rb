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
require 'rspec/mocks/standalone'

require 'scalene'

require 'helpers/macros'
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
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false
  MOCK_ACCOUNT_ID = '2744ccd10c7533bd736ad890f9dd5cab2adb27b07d500b9493f29cdc420cb2e0'

  KVS_ACCESS_ID = '058b3468a710ff315a72407cc31c14a4026d023c'
  KVS_SECRET_KEY = '9461c1bc13d3d1d6d8350a54c41aacdf298615a0'
  KVS_ACCOUNT_ID = !MOCKING_ENABLED ? '512709533065' : MOCK_ACCOUNT_ID
  KVS_HOST = '16.49.184.32'
  KVS_PORT = '9242'
  SEC_KVS_ACCESS_ID = 'baa67dcf7f9205a1099e6c80ac90e8320fd5e693'
  SEC_KVS_SECRET_KEY = 'bfa70bb715f206d515c590ed2a9cfd8f6e2db59b'
  SEC_KVS_ACCOUNT_ID = !MOCKING_ENABLED ? '955403590127' : MOCK_ACCOUNT_ID

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "BEWARE: It is an experimental attempt. Many tests may fail."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against KVS http://#{KVS_HOST}:#{KVS_PORT}..."
  end
end

