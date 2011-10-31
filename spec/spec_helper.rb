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

  ### set these env. vars with appropriate data manually.
  OS_STORAGE_AUTH_URL         = ENV['OS_STORAGE_AUTH_URL'] || "https://objects.hpcloudsvc.com/auth/v1.0"
  OS_STORAGE_ACCOUNT_USERNAME = ENV['OS_STORAGE_ACCOUNT_USERNAME'] || "<your <access key 1>"
  OS_STORAGE_ACCOUNT_PASSWORD = ENV['OS_STORAGE_ACCOUNT_PASSWORD'] || "<your secret key 1>"
  OS_STORAGE_SEC_ACCOUNT_USERNAME = ENV['OS_STORAGE_SEC_ACCOUNT_USERNAME'] || "<your access key 2>"
  OS_STORAGE_SEC_ACCOUNT_PASSWORD = ENV['OS_STORAGE_SEC_ACCOUNT_PASSWORD'] || "<your secret key 2>"

  OS_COMPUTE_AUTH_URL         = ENV['OS_COMPUTE_AUTH_URL']  || "https://compute.hpcloudsvc.com/v1.1/"
  OS_COMPUTE_ACCOUNT_USERNAME = ENV['OS_COMPUTE_ACCOUNT_USERNAME']  || "<your <access key>"
  OS_COMPUTE_ACCOUNT_PASSWORD = ENV['OS_COMPUTE_ACCOUNT_PASSWORD']  || "<your secret key>"

  EC2_COMPUTE_AUTH_URL         = ENV['EC2_COMPUTE_AUTH_URL']  || "https://compute.hpcloudsvc.com/services/Cloud/"
  EC2_COMPUTE_ACCOUNT_USERNAME = ENV['EC2_COMPUTE_ACCOUNT_USERNAME']  || "<your <access key>"
  EC2_COMPUTE_ACCOUNT_PASSWORD = ENV['EC2_COMPUTE_ACCOUNT_PASSWORD']  || "<your secret key>"

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against HP OpenStack Storage (Swift) instance: #{OS_STORAGE_AUTH_URL}..."
    puts "and HP OpenStack (EC2 compatibility) Compute (Nova) instance: #{EC2_COMPUTE_AUTH_URL}..."
  end
end

