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
require 'helpers/keypairs'
require 'helpers/addresses'
require 'helpers/securitygroups'

RSpec.configure do |config|
  
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false

  OS_STORAGE_AUTH_URL         = ENV['OS_STORAGE_AUTH_URL']  || "http://swift.nv1.devex.me:8080/auth/v1.0"
  OS_STORAGE_ACCOUNT_USERNAME = ENV['OS_STORAGE_ACCOUNT_USERNAME']  || "dev_26879407200539:dev_77550147347364" # fog_tester1@test.com/FogTest123
  OS_STORAGE_ACCOUNT_PASSWORD = ENV['OS_STORAGE_ACCOUNT_PASSWORD']  || "CuLqhwVWLaxXkFDYjPFUGNYAgsq4qu7c4U5"
  OS_STORAGE_SEC_ACCOUNT_USERNAME = ENV['OS_STORAGE_SEC_ACCOUNT_USERNAME']  || "dev_31963196353900:dev_40709621046377"  # fog_tester2@test.com/FogTest123
  OS_STORAGE_SEC_ACCOUNT_PASSWORD = ENV['OS_STORAGE_SEC_ACCOUNT_PASSWORD']  || "rhAz1B5ALIjzV1kuaduIwxY4T5t0awrFA7o"

  OS_COMPUTE_AUTH_URL         = ENV['OS_COMPUTE_AUTH_URL']  || "http://15.184.4.165:8774/v1.0" # "http://15.9.138.42:8774/v1.1"
  OS_COMPUTE_ACCOUNT_USERNAME = ENV['OS_COMPUTE_ACCOUNT_USERNAME']  || "rupak3" #"user10"
  OS_COMPUTE_ACCOUNT_PASSWORD = ENV['OS_COMPUTE_ACCOUNT_PASSWORD']  || "6cd0104b-c0e6-4f6e-8a00-427142bb4a8c" # "221a5420-bf8e-4ff9-a108-0be01689de97"

  EC2_COMPUTE_AUTH_URL         = ENV['EC2_COMPUTE_AUTH_URL']  || "http://15.184.4.165:8773/services/Cloud"
  EC2_COMPUTE_ACCOUNT_USERNAME = ENV['EC2_COMPUTE_ACCOUNT_USERNAME']  || "6cd0104b-c0e6-4f6e-8a00-427142bb4a8c:rupak3"
  EC2_COMPUTE_ACCOUNT_PASSWORD = ENV['EC2_COMPUTE_ACCOUNT_PASSWORD']  || "752219ad-5984-4690-be2e-aa743b5e7212"

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

