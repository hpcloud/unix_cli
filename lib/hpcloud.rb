require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

require 'hpcloud/resource'
require 'hpcloud/bucket'

module HPCloud
  class CLI < Thor
    
    # export KVS_TEST_HOST=16.49.184.31
    # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9232 "Unix CLI" "unix.cli@hp.com"
    
    ACCESS_ID = '9cb90f0dcb0fe61380b971e68ed4efb11beb6bfc'
    SECRET_KEY = 'b04517f6189f3695b9804d69cd6925715a531be5'
    ACCOUNT_ID = '7725f6e048ceb766a546842adc07d22a22c5f930'
    HOST = '16.49.184.31'
    PORT = '9232'
    
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