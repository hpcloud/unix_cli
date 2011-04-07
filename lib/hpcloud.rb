#require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

require 'hpcloud/version'
require 'hpcloud/config'
require 'hpcloud/resource'
require 'hpcloud/bucket'

require 'hpcloud/cli'

require 'hpcloud/commands/info'
require 'hpcloud/commands/account'
require 'hpcloud/commands/buckets'
require 'hpcloud/commands/list'
#require 'hpcloud/commands/touch'
require 'hpcloud/commands/copy'
require 'hpcloud/commands/move'
require 'hpcloud/commands/remove'
#require 'hpcloud/commands/acl'
require 'hpcloud/commands/location'
#require 'hpcloud/commands/versioning'