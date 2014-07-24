# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
require 'helpers/keypair_test_helper'
require 'helpers/network_test_helper'
require 'helpers/port_test_helper'
require 'helpers/test_response'
require 'helpers/io'
require 'helpers/containers'
require 'helpers/container_helper'
require 'helpers/keypairs'
require 'helpers/addresses'
require 'helpers/securitygroups'
require 'helpers/securitygroup_test_helper'
require 'helpers/subnet_test_helper'
require 'helpers/image_test_helper'
require 'helpers/rule_test_helper'
require 'helpers/server_test_helper'
require 'helpers/snapshot_test_helper'
require 'helpers/volume_test_helper'
require 'helpers/volume_attachment_helper'

REGION='regionOne'

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
