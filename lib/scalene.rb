#require "bundler/setup"
require 'fog'

require 'scalene/version'
require 'scalene/config'
require 'scalene/resource'
require 'scalene/container'

require 'scalene/cli'

require 'scalene/commands/info'
require 'scalene/commands/account'
require 'scalene/commands/containers'
require 'scalene/commands/list'
#require 'scalene/commands/touch'
require 'scalene/commands/copy'
require 'scalene/commands/move'
require 'scalene/commands/remove'
require 'scalene/commands/acl'
require 'scalene/commands/location'
#require 'scalene/commands/versioning'
require 'scalene/commands/get'
