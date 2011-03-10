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
    define_method "buckets:add" do |name|
      begin
        connection.directories.create(:key => name)
        puts "Created bucket '#{name}'."
      rescue Excon::Errors::Conflict => error
        display_error_message(error)
      end
    end
    
    desc "buckets:rm <name>", "remove a bucket"
    define_method "buckets:rm" do |name|
      bucket = connection.directories.get(name)
      if bucket
        begin
          bucket.destroy
          puts "Removed bucket '#{name}'."
        end
      else
        puts "You don't have a bucket named '#{name}'."
      end
    end
    
    desc 'ls <bucket>', "list bucket contents"
    def ls(name='')
      return buckets if name.empty?
      begin
        directory = connection.directories.get(name)
        if directory
          directory.files.each { |file| puts file.key }
        else
          puts "You don't have a directory named '#{name}'"
        end
      rescue Excon::Errors::Forbidden => error
        display_error_message(error)
      end
    end
    
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

