$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'hpcloud'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
  # export KVS_TEST_HOST=16.49.184.31
  # build/opt-centos5-x86_64/bin/stout-mgr create-account -port 9233 "Unix CLI" "unix.cli@hp.com"
  KVS_ACCESS_ID = '0b861f6bb7295cc1f895a7f123ea2da83706466e'
  KVS_SECRET_KEY = 'de7d34abec8191b2e97c2593e33da53cb1b2b1a5'
  KVS_ACCOUNT_ID = 'b3ffd6019a70977c27b8ecb00d85c775af32705e'
  KVS_HOST = '16.49.184.31'
  KVS_PORT = '9233'
  
  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  
  # Create a new Storage service connection - maybe memoize later
  def storage_connection
    Fog::HP::Storage.new( :hp_access_id =>  KVS_ACCESS_ID,
                          :hp_secret_key => KVS_SECRET_KEY,
                          :hp_account_id => KVS_ACCOUNT_ID,
                          :host => KVS_HOST,
                          :port => KVS_PORT )
  end

  # Generate a unique bucket name
  # def bucket_name(seed=random_string(5))
  #   'fog_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s 
  # end

  # Delete any buckets this connection currently has
  # def purge_buckets(connection = nil, verbose = false)
  #   connection ||= storage_connection
  #   connection.directories.each do |directory|
  #     purge_bucket(directory.key, :connection => connection, :verbose => verbose)
  #   end
  # end

  # Delete a single bucket, regardless of files present
  def purge_bucket(bucket_name, options={})
    connection = options[:connection] || @kvs
    verbose = options[:verbose] || false
    begin
      puts "Deleting '#{bucket_name}'" if verbose
      connection.delete_bucket(bucket_name)
    rescue Excon::Errors::NotFound # bucket is listed, but does not currently exist
    rescue Excon::Errors::Forbidden
      connection.put_bucket_acl(bucket_name, standard_acl)
      purge_bucket(bucket_name, options)
    rescue Excon::Errors::Conflict # bucket has files in it
      begin
        connection.directories.get(bucket_name).files.each do |file|
          begin
            puts "  - removing file '#{file.key}'" if verbose
            file.destroy
          end
        end
        connection.delete_bucket(bucket_name)
      rescue Excon::Errors::Forbidden
        connection.put_bucket_acl(bucket_name, standard_acl)
        purge_bucket(bucket_name, options)
      end
    end
  end

  def create_bucket_with_files(bucket_name, *files)
    #bucket_name = bucket_name(bucket_seed)
    @kvs.put_bucket(bucket_name)
    files.each do |file_name|
      @kvs.put_object(bucket_name, file_name, read_file(file_name))
    end
    bucket_name
  end

  def read_file(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/files/#{filename}")
  end
  
  def read_account_file(filename)
    File.read(File.dirname(__FILE__) + "/fixtures/accounts/#{filename}")
  end
  
end
