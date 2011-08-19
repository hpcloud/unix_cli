require "bundler/setup"
require 'fog'

require 'hpcloud/version'
require 'hpcloud/config'
require 'hpcloud/resource'
require 'hpcloud/container'

require 'hpcloud/cli'

require 'hpcloud/commands/info'
require 'hpcloud/commands/account'
require 'hpcloud/commands/containers'
require 'hpcloud/commands/list'
#require 'hpcloud/commands/touch'
require 'hpcloud/commands/copy'
require 'hpcloud/commands/move'
require 'hpcloud/commands/remove'
#require 'hpcloud/commands/acl'
#require 'hpcloud/commands/location'
#require 'hpcloud/commands/versioning'
require 'hpcloud/commands/get'

require 'hpcloud/commands/servers'
require 'hpcloud/commands/flavors'
require 'hpcloud/commands/images'
require 'hpcloud/commands/keypairs'
require 'hpcloud/commands/addresses'

