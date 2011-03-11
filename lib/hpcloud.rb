require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

require 'hpcloud/bucket'

module HPCloud
  class CLI < Thor
    
    ## Constants
    CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write bucket-owner-read bucket-owner-full-control log-delivery-write)
    
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
        name = Bucket.bucket_name_for_service(name)
        connection.directories.create(:key => name)
        puts "Created bucket '#{name}'."
      rescue Excon::Errors::Conflict => error
        display_error_message(error)
      end
    end
    
    desc "buckets:rm <name>", "remove a bucket"
    method_option :force, :default => false, :type => :boolean, :aliases => '-f'
    define_method "buckets:rm" do |name|
      name = Bucket.bucket_name_for_service(name)
      bucket = connection.directories.get(name)
      if bucket
        if options.force?
          bucket.files.each { |file| file.destroy }
        end
        begin
          bucket.destroy
          puts "Removed bucket '#{name}'."
        rescue Excon::Errors::Conflict => error
          display_error_message(error)
        end
      else
        puts "You don't have a bucket named '#{name}'."
      end
    end
    
    desc 'ls <bucket>', "list bucket contents"
    def ls(name='')
      return buckets if name.empty?
      name = Bucket.bucket_name_for_service(name)
      begin
        directory = connection.directories.get(name)
        if directory
          directory.files.each { |file| puts file.key }
        else
          puts "You don't have a bucket named '#{name}'"
        end
      rescue Excon::Errors::Forbidden => error
        display_error_message(error)
      end
    end
    
    desc 'cp <resource> <resource>', "copy files from one resource to another"
    def cp(from, to)
      if !File.exists?(from)
        puts "File not found at '#{from}'."
        return
      end
      mime_type = get_mime_type(from)
      bucket, path = parse_bucket_resource(to)
      directory = connection.directories.get(bucket)
      key = Bucket.storage_destination_path(path, from)
      if directory
        begin
          directory.files.create(:key => key, :body => File.open(from), 'Content-Type' => mime_type)
          puts "Copied #{from} => :#{bucket}/#{key}"
        end
      else
        puts "You don't have a bucket '#{bucket}'."
      end
    end
    
    desc 'acl <resource> <canned-acl>', "set a given resource to a canned ACL"
    def acl(resource, acl)
      acl = acl.downcase
      unless CANNED_ACLS.include?(acl)
        puts "Your ACL '#{acl}' is invalid.\nValid options are: #{CANNED_ACLS.join(', ')}."
        return
      end
      bucket, path = parse_bucket_resource(resource)
      directory = connection.directories.get(bucket)
      if directory
        file = directory.files.get(path)
        if file
          begin
            connection.put_object_acl(bucket, path, acl)
            # can't use model for now as doesn't preserve content-type
            # file.acl = acl
            # file.save
            puts "ACL for #{resource} updated to #{acl}"
          end
        else
          puts "You don't have a file '#{path}'."
        end
      else
        puts "You don't have a bucket '#{bucket}'."
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
    
    def parse_bucket_resource(resource)
      bucket, *rest = resource.split('/')
      #raise "No bucket resource in '#{resource}'." if bucket[0] != ':'
      bucket = bucket[1..-1] if bucket[0] == ':'
      path = rest.empty? ? nil : rest.join('/')
      path << '/' if resource[-1] == '/'
      return bucket, path
    end
    
    def display_error_message(error)
      puts parse_error(error.response)
    end
    
    def parse_error(response)
      response.body =~ /<Message>(.*)<\/Message>/
      return $1 if $1
      response.body
    end
    
    def get_mime_type(file)
      # this probably needs some security lovin'
      full_mime = `file --mime -b #{file}`
      full_mime.split(';')[0].chomp
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

