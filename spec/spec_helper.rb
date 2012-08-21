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
require 'helpers/accounts_helper'
require 'helpers/config_helper'
require 'helpers/connections'
require 'helpers/directory_helper'
require 'helpers/test_response'
require 'helpers/io'
require 'helpers/containers'
require 'helpers/container_helper'
require 'helpers/servers'
require 'helpers/keypairs'
require 'helpers/addresses'
require 'helpers/securitygroups'
require 'helpers/server_test_helper'
require 'helpers/volume_test_helper'
require 'helpers/volume_attachment_helper'

RSpec.configure do |config|
  
  MOCKING_ENABLED = ENV['ENABLE_CLI_MOCKING'] || false

  HOSTNAME                    = `hostname`.chomp
  RANDOM_CHARS                = [('a'..'z')].map{|i| i.to_a}.flatten

  OS_COMPUTE_BASE_IMAGE_ID    = ENV['OS_COMPUTE_BASE_IMAGE_ID'] || "your image"
  OS_COMPUTE_BASE_FLAVOR_ID   = ENV['OS_COMPUTE_BASE_FLAVOR_ID'] || "your flav"

  config.before(:each) { HP::Cloud::Connection.instance.set_options({}) }

  if MOCKING_ENABLED
    puts "==========================================================="
    puts "Running tests in mocking mode..."
    puts "==========================================================="
    # Enable mocking
    Fog.mock!
  else
    puts "Running tests against HP Cloud Services..."
  end

  # Generate a unique resource name
  def resource_name(seed=random_string(5))
    'fog_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s
  end

end

include HP::Cloud
