$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

if ENV['SPEC_CODE_COVERAGE'] and RUBY_VERSION[2,1] == '9'
  puts "Using simplecov..."
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
    add_group "Commands", "/lib/hpcloud/commands"
  end
end

require 'rspec'
require 'rspec/mocks/standalone'

require 'hpcloud'

require 'helpers/macros'
require 'helpers/fixtures'
require 'helpers/connections'
require 'helpers/io'
require 'helpers/configs'
require 'helpers/containers'

RSpec.configure do |config|
  
  # export KVS_TEST_HOST=16.49.184.31
  # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9233 "Unix CLI" "unix.cli@hp.com"
  #
  # http://16.49.184.32:9242/kvs/keygen.html
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false

  OS_STORAGE_AUTH_URL         = ENV['OS_STORAGE_AUTH_URL']  || "http://swift.nv1.devex.me:8080/auth/v1.0"  # "http://agpa-ge1.csbu.hpl.hp.com/auth/v1.0"
  OS_STORAGE_ACCOUNT_USERNAME = ENV['OS_STORAGE_ACCOUNT_USERNAME']  || "dev_26879407200539:dev_77550147347364" # fog_tester1@test.com/FogTest123
  OS_STORAGE_ACCOUNT_PASSWORD = ENV['OS_STORAGE_ACCOUNT_PASSWORD']  || "CuLqhwVWLaxXkFDYjPFUGNYAgsq4qu7c4U5"
  OS_STORAGE_SEC_ACCOUNT_USERNAME = ENV['OS_STORAGE_SEC_ACCOUNT_USERNAME']  || "dev_31963196353900:dev_40709621046377"  # fog_tester2@test.com/FogTest123
  OS_STORAGE_SEC_ACCOUNT_PASSWORD = ENV['OS_STORAGE_SEC_ACCOUNT_PASSWORD']  || "rhAz1B5ALIjzV1kuaduIwxY4T5t0awrFA7o"

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "BEWARE: It is an experimental attempt. Many tests may fail."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
#    puts "Running tests against KVS http://#{KVS_HOST}:#{KVS_PORT}..."
    puts "Running tests against HP OpenStack Storage (Swift) instance: #{OS_STORAGE_AUTH_URL}..."
  end
end

