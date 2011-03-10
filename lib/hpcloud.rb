require 'thor'
require 'thor/group'

require 'hpcloud/storage'

module HPCloud
  class CLI < Thor
    
    desc "buckets", "list available buckets"
    def buckets
      puts "bucket listing"
    end
      
    desc "buckets:add <name>", "add a bucket"
    define_method "buckets:add" do
      puts "add a bucket"
    end
    
    desc "buckets:rm <name>", "remove a bucket"
    define_method "buckets:rm" do
      puts "remove bucket"
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

