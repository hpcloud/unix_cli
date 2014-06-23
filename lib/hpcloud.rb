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

# require "bundler/setup" # Comment out for delivery
require 'fog'

require 'hpcloud/version'
require 'hpcloud/error_response'
require 'hpcloud/cli_status'
require 'hpcloud/monkey'
require 'hpcloud/columns'
require 'hpcloud/log'

require 'hpcloud/base_helper'
require 'hpcloud/address_helper'
require 'hpcloud/database_helper'
require 'hpcloud/dns_helper'
require 'hpcloud/floating_ip_helper'
require 'hpcloud/image_helper'
require 'hpcloud/keypair_helper'
require 'hpcloud/network_helper'
require 'hpcloud/port_helper'
require 'hpcloud/rule_helper'
require 'hpcloud/security_group_helper'
require 'hpcloud/server_helper'
require 'hpcloud/snapshot_helper'
require 'hpcloud/subnet_helper'
require 'hpcloud/volume_helper'

require 'hpcloud/accounts'
require 'hpcloud/auth_cache'
require 'hpcloud/acl'
require 'hpcloud/acl_cmd'
require 'hpcloud/addresses'
require 'hpcloud/checker'
require 'hpcloud/databases'
require 'hpcloud/dnss'
require 'hpcloud/config'
require 'hpcloud/flavors'
require 'hpcloud/floating_ips'
require 'hpcloud/fog_collection'
require 'hpcloud/keypairs'
require 'hpcloud/networks'
require 'hpcloud/ports'
require 'hpcloud/lbs'
require 'hpcloud/images'
require 'hpcloud/metadata'
require 'hpcloud/progress'
require 'hpcloud/resource_factory'
require 'hpcloud/routers'
require 'hpcloud/rules'
require 'hpcloud/security_groups'
require 'hpcloud/servers'
require 'hpcloud/snapshots'
require 'hpcloud/subnets'
require 'hpcloud/tableizer'
require 'hpcloud/time_parser'
require 'hpcloud/volumes'
require 'hpcloud/volume_attachment'
require 'hpcloud/volume_attachments'

require 'hpcloud/cli'

require 'hpcloud/commands/account'
require 'hpcloud/commands/acl'
require 'hpcloud/commands/addresses'
require 'hpcloud/commands/cdn_containers'
require 'hpcloud/commands/complete'
require 'hpcloud/commands/config'
require 'hpcloud/commands/containers'
require 'hpcloud/commands/copy'
require 'hpcloud/commands/dns'
require 'hpcloud/commands/flavors'
require 'hpcloud/commands/get'
require 'hpcloud/commands/images'
require 'hpcloud/commands/keypairs'
require 'hpcloud/commands/lb'
require 'hpcloud/commands/list'
require 'hpcloud/commands/location'
require 'hpcloud/commands/networks'
require 'hpcloud/commands/metadata'
require 'hpcloud/commands/metadata/set'
require 'hpcloud/commands/ports'
require 'hpcloud/commands/info'
require 'hpcloud/commands/migrate'
require 'hpcloud/commands/move'
require 'hpcloud/commands/remove'
require 'hpcloud/commands/routers'
require 'hpcloud/commands/servers'
require 'hpcloud/commands/securitygroups'
require 'hpcloud/commands/snapshots'
require 'hpcloud/commands/subnets'
require 'hpcloud/commands/tempurl'
require 'hpcloud/commands/volumes'
