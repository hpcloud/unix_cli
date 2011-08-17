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
require 'helpers/servers'

RSpec.configure do |config|
  
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false

  OS_STORAGE_AUTH_URL         = ENV['OS_STORAGE_AUTH_URL']  || "http://15.184.3.19:8080/auth/v1.0"  # "http://agpa-ge1.csbu.hpl.hp.com/auth/v1.0"
  OS_STORAGE_ACCOUNT_USERNAME = ENV['OS_STORAGE_ACCOUNT_USERNAME']  || "account1:user1"    # "fog_tester1:fog_tester1"
  OS_STORAGE_ACCOUNT_PASSWORD = ENV['OS_STORAGE_ACCOUNT_PASSWORD']  || "pass1"             # "fog_tester1"
  OS_STORAGE_SEC_ACCOUNT_USERNAME = ENV['OS_STORAGE_SEC_ACCOUNT_USERNAME']  || "account2:user2"   # "fog_tester2:fog_tester2"
  OS_STORAGE_SEC_ACCOUNT_PASSWORD = ENV['OS_STORAGE_SEC_ACCOUNT_PASSWORD']  || "pass2"            # "fog_tester2"

  OS_COMPUTE_AUTH_URL         = ENV['OS_COMPUTE_AUTH_URL']  || "http://15.184.4.165:8774/v1.0" # "http://15.9.138.42:8774/v1.1"
  OS_COMPUTE_ACCOUNT_USERNAME = ENV['OS_COMPUTE_ACCOUNT_USERNAME']  || "rupakg" #"user10"
  OS_COMPUTE_ACCOUNT_PASSWORD = ENV['OS_COMPUTE_ACCOUNT_PASSWORD']  || "c494f753-b6dd-4e49-b89e-72199eb36f4a" # "221a5420-bf8e-4ff9-a108-0be01689de97"

  EC2_COMPUTE_AUTH_URL         = ENV['EC2_COMPUTE_AUTH_URL']  || "http://15.184.4.165:8773/services/Cloud"
  EC2_COMPUTE_ACCOUNT_USERNAME = ENV['EC2_COMPUTE_ACCOUNT_USERNAME']  || "c494f753-b6dd-4e49-b89e-72199eb36f4a:rupakg"
  EC2_COMPUTE_ACCOUNT_PASSWORD = ENV['EC2_COMPUTE_ACCOUNT_PASSWORD']  || "8d1081c4-02e2-49b7-b59b-6b532f2c6a03"

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "BEWARE: It is an experimental attempt. Many tests may fail."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against HP OpenStack Storage (Swift) instance: #{OS_STORAGE_AUTH_URL}..."
    puts "and HP OpenStack (EC2 compatibility) Compute (Nova) instance: #{EC2_COMPUTE_AUTH_URL}..."
  end
end

