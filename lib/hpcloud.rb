require "bundler/setup"
require 'thor'
require 'thor/group'
require 'fog'

require 'hpcloud/resource'
require 'hpcloud/bucket'

module HPCloud
  class CLI < Thor
    
    ## Constants
    CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write bucket-owner-read bucket-owner-full-control log-delivery-write)
    
    # export KVS_TEST_HOST=16.49.184.31
    # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9233 "Unix CLI" "unix.cli@hp.com"
    
    ACCESS_ID = '0b861f6bb7295cc1f895a7f123ea2da83706466e'
    SECRET_KEY = 'de7d34abec8191b2e97c2593e33da53cb1b2b1a5'
    ACCOUNT_ID = 'b3ffd6019a70977c27b8ecb00d85c775af32705e'
    HOST = '16.49.184.31'
    PORT = '9233'
    
    map 'create'          => 'add',
        %w(rm delete del) => 'remove',
        'cp'              => 'copy',
        'mv'              => 'move',
        'ls'              => 'list',
        %w(buckets:rm buckets:delete buckets:del) => 'buckets:remove'
        
    desc "buckets", "list available buckets"
    def buckets
      buckets = connection.directories
      if buckets.empty?
        puts "You currently have no buckets, use `hpcloud buckets:add <name>` to create one."
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
    
    desc "buckets:remove <name>", "remove a bucket"
    method_option :force, :default => false, :type => :boolean, :aliases => '-f'
    define_method "buckets:remove" do |name|
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
    
    desc 'list <bucket>', "list bucket contents"
    def list(name='')
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
    
    desc 'touch <resource>', "create an empty object"
    def touch(resource)
      puts "touch an object"
    end
    
    desc 'copy <resource> <resource>', "copy files from one resource to another"
    long_desc 'So much more description...'
    def copy(from, to)
      from_type = Resource.detect_type(from)
      to_type   = Resource.detect_type(to)
      if from_type == :file and Resource::REMOTE_TYPES.include?(to_type)
        put(from, to)
      elsif from_type == :object and Resource::LOCAL_TYPES.include?(to_type)
        fetch(from, to)
      else
        puts "Not currently supported."
      end
    end
    
    no_tasks do
      
      def fetch(from, to)
        dir_path = File.dirname(to) #File.expand_path(file_path)
        if !Dir.exists?(dir_path)
          puts "No directory exists at '#{dir_path}'."
          return
        end
        bucket, path = Bucket.parse_resource(from)
        # TODO - ensure expansion to file_destination_path
        directory = connection.directories.get(bucket)
        if directory
          begin
            get = connection.get_object(bucket, path)
            File.open(to, 'w') do |file|
              file.write get.body
            end
            puts "Copied #{from} => #{to}"
          rescue Excon::Errors::NotFound => e
            puts "The specified object does not exist."
          end
        else
          puts "You don't have a bucket '#{bucket}'."
        end
      end
      
      def put(from, to)
        if !File.exists?(from)
          puts "File not found at '#{from}'."
          return
        end
        mime_type = Resource.get_mime_type(from)
        bucket, path = Bucket.parse_resource(to)
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
      
      def clone(from, to)
      end
      
    end
    
    desc 'move <resource> <resource>', 'move objects inside or between buckets'
    def move(from,to)
      puts "move an object"
    end
    
    desc 'remove <resource>', 'remove an object'
    
    def remove(resource)
      puts "remove an object"
    end
    
    desc 'location <resource>', 'display the URI for a given resource'
    def location(resource)
      bucket, key = Bucket.parse_resource(resource)
      begin
        exists = connection.head_object(bucket, key)
        if exists
          puts "http://#{HOST}:#{PORT}/#{bucket}/#{key}"
        end
      rescue Excon::Errors::NotFound => error
        puts "No object exists at '#{bucket}/#{key}'."
      end
    end
    
    desc 'acl <resource> <canned-acl>', "set a given resource to a canned ACL"
    def acl(resource, acl)
      acl = acl.downcase
      unless CANNED_ACLS.include?(acl)
        puts "Your ACL '#{acl}' is invalid.\nValid options are: #{CANNED_ACLS.join(', ')}."
        return
      end
      bucket, path = Bucket.parse_resource(resource)
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
    
    desc 'versioning <bucket>', 'show or modify versioning state for a bucket'
    def versioning(new_state=nil)
      puts "show versioning state"
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

