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

  HOSTNAME                    = `hostname`.chomp
  RANDOM_CHARS                = [('a'..'z')].map{|i| i.to_a}.flatten

  ### Dev creds. set these env. vars with appropriate data manually.
  OS_STORAGE_AUTH_URL         = ENV['OS_STORAGE_AUTH_URL'] || "https://objects.hpcloudsvc.com/auth/v1.0"
  OS_STORAGE_ACCOUNT_USERNAME = ENV['OS_STORAGE_ACCOUNT_USERNAME'] || "<your <access key 1>"
  OS_STORAGE_ACCOUNT_PASSWORD = ENV['OS_STORAGE_ACCOUNT_PASSWORD'] || "<your secret key 1>"
  OS_STORAGE_ACCOUNT_TENANT_ID = ENV['OS_STORAGE_ACCOUNT_TENANT_ID'] || "<your tenant id>"
  OS_STORAGE_ACCOUNT_AVL_ZONE      = ENV['OS_STORAGE_ACCOUNT_AVL_ZONE'] || "<your avl zone>"
  OS_STORAGE_SEC_ACCOUNT_USERNAME = ENV['OS_STORAGE_SEC_ACCOUNT_USERNAME'] || "<your access key 2>"
  OS_STORAGE_SEC_ACCOUNT_PASSWORD = ENV['OS_STORAGE_SEC_ACCOUNT_PASSWORD'] || "<your secret key 2>"
  OS_STORAGE_SEC_ACCOUNT_TENANT_ID = ENV['OS_STORAGE_SEC_ACCOUNT_TENANT_ID'] || "<your tenant id>"
  OS_STORAGE_SEC_ACCOUNT_AVL_ZONE  = ENV['OS_STORAGE_SEC_ACCOUNT_AVL_ZONE'] || "<your avl zone>"

  OS_COMPUTE_AUTH_URL         = ENV['OS_COMPUTE_AUTH_URL']  || "https://compute.hpcloudsvc.com/v1.1/"
  OS_COMPUTE_ACCOUNT_USERNAME = ENV['OS_COMPUTE_ACCOUNT_USERNAME']  || "<your <access key>"
  OS_COMPUTE_ACCOUNT_PASSWORD = ENV['OS_COMPUTE_ACCOUNT_PASSWORD']  || "<your secret key>"
  OS_COMPUTE_ACCOUNT_TENANT_ID = ENV['OS_COMPUTE_ACCOUNT_TENANT_ID'] || "<your tenant id>"
  OS_COMPUTE_ACCOUNT_AVL_ZONE = ENV['OS_COMPUTE_ACCOUNT_AVL_ZONE'] || "<your avl zone>"
  OS_COMPUTE_BASE_IMAGE_ID    = ENV['OS_COMPUTE_BASE_IMAGE_ID'] || "your image id"
  OS_COMPUTE_BASE_FLAVOR_ID   = ENV['OS_COMPUTE_BASE_FLAVOR_ID'] || "your flavor id"
  HP::Cloud::Config.set_credentials('secondary', OS_STORAGE_SEC_ACCOUNT_USERNAME, OS_STORAGE_SEC_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_SEC_ACCOUNT_TENANT_ID)
  HP::Cloud::Config.set_credentials('primary', OS_STORAGE_ACCOUNT_USERNAME, OS_STORAGE_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_ACCOUNT_TENANT_ID)
  HP::Cloud::Config.set_credentials('compute', OS_COMPUTE_ACCOUNT_USERNAME, OS_COMPUTE_ACCOUNT_PASSWORD, OS_COMPUTE_AUTH_URL, OS_COMPUTE_ACCOUNT_TENANT_ID)
  HP::Cloud::Config.set_credentials('default', OS_STORAGE_ACCOUNT_USERNAME, OS_STORAGE_ACCOUNT_PASSWORD, OS_STORAGE_AUTH_URL, OS_STORAGE_ACCOUNT_TENANT_ID)

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against HP Cloud Services with CS endpoint: #{OS_STORAGE_AUTH_URL}..."
  end

  # Generate a unique resource name
  def resource_name(seed=random_string(5))
    'fog_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s
  end

end

