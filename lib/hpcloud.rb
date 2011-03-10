require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

#require 'hpcloud/storage'

module HPCloud
  class CLI < Thor
    
    ## Constants
    ACCESS_ID = 'cecf0acbcf6add394cc526b93a0017e151a76fbb'
    SECRET_KEY = 'd8a8bf2d86ef9d2a9b258120858e3973608f41e6'
    ACCOUNT_ID = '1ba31f9b7a1adbb28cb1495e0fb2ac65ef82b34a'
    HOST = '16.49.184.31'
    PORT = '9233'
        
    desc "buckets", "list available buckets"
    def buckets
      buckets = connection.directories
      if buckets.empty?
        puts "You currently have no buckets, use `hpcloud add <name>` to create one."
      else
        buckets.each { |bucket| puts bucket.key }
      end
    end
      
    desc "buckets:add <name>", "add a bucket"
    define_method "buckets:add" do
      puts "add a bucket"
    end
    
    desc "buckets:rm <name>", "remove a bucket"
    define_method "buckets:rm" do
      puts "remove bucket"
    end
    
    private
    
    def connection
      @connection ||= Fog::HP::Storage.new( :hp_access_id =>  ACCESS_ID,
                                            :hp_secret_key => SECRET_KEY,
                                            :hp_account_id => ACCOUNT_ID,
                                            :host => HOST,
                                            :port => PORT )
    end
    
  end
  
  
  
  # class Credentials < Thor
  #   desc "setup", "set up your credentials"
  #   def setup
  #     puts "hello"
  #   end
  # 
  #   desc "generate", "generate a set of KVS credentials"
  #   def generate
  #     puts "more fun"
  #   end
  # end
  # 
  # CLI.register(Credentials, "credentials", "credentials", "long")
  
end

