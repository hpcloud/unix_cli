require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

require 'hpcloud/resource'
require 'hpcloud/bucket'

module HPCloud
  class CLI < Thor
    
    # export KVS_TEST_HOST=16.49.184.31
    # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9233 "Unix CLI" "unix.cli@hp.com"
    
    ACCESS_ID = '0b861f6bb7295cc1f895a7f123ea2da83706466e'
    SECRET_KEY = 'de7d34abec8191b2e97c2593e33da53cb1b2b1a5'
    ACCOUNT_ID = 'b3ffd6019a70977c27b8ecb00d85c775af32705e'
    HOST = '16.49.184.31'
    PORT = '9233'
    
    private
    
    def connection
      @connection ||= Fog::HP::Storage.new( :hp_access_id =>  ACCESS_ID,
                                            :hp_secret_key => SECRET_KEY,
                                            :hp_account_id => ACCOUNT_ID,
                                            :host => HOST,
                                            :port => PORT )
    end
    
    def display_error_message(error)
      puts parse_error(error.response)
    end
    
    def parse_error(response)
      response.body =~ /<Message>(.*)<\/Message>/
      return $1 if $1
      response.body
    end
    
  end
  
end

require 'hpcloud/commands/buckets'
require 'hpcloud/commands/list'
require 'hpcloud/commands/touch'
require 'hpcloud/commands/copy'
require 'hpcloud/commands/move'
require 'hpcloud/commands/remove'
require 'hpcloud/commands/acl'
require 'hpcloud/commands/location'
require 'hpcloud/commands/versioning'