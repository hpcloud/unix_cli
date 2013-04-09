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

require 'helpers/fixtures'
require 'helpers/accounts_helper'
require 'helpers/auth_cache_helper'
require 'helpers/checker_helper'
require 'helpers/config_helper'
require 'helpers/connections'
require 'helpers/container_helper'
require 'helpers/directory_helper'
require 'helpers/dns_test_helper'
require 'helpers/lbaas_test_helper'
require 'helpers/keypair_test_helper'
require 'helpers/network_test_helper'
require 'helpers/port_test_helper'
require 'helpers/keypairs'
require 'helpers/addresses'
require 'helpers/router_test_helper'
require 'helpers/securitygroups'
require 'helpers/securitygroup_test_helper'
require 'helpers/subnet_test_helper'
require 'helpers/image_test_helper'
require 'helpers/server_test_helper'
require 'helpers/snapshot_test_helper'
require 'helpers/volume_test_helper'
require 'helpers/volume_attachment_helper'

require 'helpers/containers'
require 'helpers/test_response'
require 'helpers/io'

RSpec.configure do |config|
  
  HOSTNAME                    = `hostname`.chomp
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false
  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against: #{AccountsHelper.get_uri()}..."
  end

  def reset_all
    AccountsHelper.reset()
    AuthCacheHelper.reset()
    ConfigHelper.reset()
    HP::Cloud::Connection.instance.clear_options()
  end

  # Generate a unique resource name
  def resource_name(seed=random_string(5))
    'cli_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s
  end

end

include HP::Cloud
