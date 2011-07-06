
RSpec.configure do |config|
  
  # Generate a unique bucket name
  # def bucket_name(seed=random_string(5))
  #   'fog_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s 
  # end

  # Delete any buckets this connection currently has
  def purge_buckets(connection = nil, verbose = false)
    connection ||= storage_connection
    connection.directories.each do |directory|
      purge_bucket(directory.key, :connection => connection, :verbose => verbose)
    end
  end

  # Delete a single bucket, regardless of files present
  def purge_bucket(bucket_name, options={})
    connection = options[:connection] || @kvs
    verbose = options[:verbose] || false
    begin
      puts "Deleting '#{bucket_name}'" if verbose
      connection.delete_container(bucket_name)
    rescue Fog::HP::Storage::NotFound # bucket is listed, but does not currently exist
    rescue Excon::Errors::Conflict # bucket has files in it
      begin
        connection.directories.get(bucket_name).files.each do |file|
          begin
            puts "  - removing file '#{file.key}'" if verbose
            file.destroy
          end
        end
        connection.delete_container(bucket_name)
      end
    end
  end

  def create_bucket_with_files(bucket_name, *files)
    #bucket_name = bucket_name(bucket_seed)
    @kvs.put_container(bucket_name)
    files.each do |file_name|
      @kvs.put_object(bucket_name, file_name, read_file(file_name))
    end
    bucket_name
  end
  
end