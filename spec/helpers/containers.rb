
RSpec.configure do |config|
  
  # Generate a unique container name
  # def container_name(seed=random_string(5))
  #   'fog_' << HOSTNAME << '_' << Time.now.to_i.to_s << '_' << seed.to_s 
  # end

  # Delete any containers this connection currently has
  def purge_containers(connection = nil, verbose = false)
    connection ||= storage_connection
    connection.directories.each do |directory|
      purge_container(directory.key, :connection => connection, :verbose => verbose)
    end
  end

  # Delete a single container, regardless of files present
  def purge_container(container_name, options={})
    connection = options[:connection] || @hp_svc
    verbose = options[:verbose] || false
    begin
      puts "Deleting '#{container_name}'" if verbose
      connection.delete_container(container_name) unless connection.nil?
    rescue Fog::Storage::HP::NotFound # container is listed, but does not currently exist
    rescue Excon::Errors::Conflict # container has files in it
      begin
        connection.directories.get(container_name).files.each do |file|
          begin
            puts "  - removing file '#{file.key}'" if verbose
            file.destroy
          end
        end
        connection.delete_container(container_name)
      end
    end
  end

  def create_container_with_files(container_name, *files)
    #container_name = container_name(container_seed)
    @hp_svc.put_container(container_name)
    files.each do |file_name|
      @hp_svc.put_object(container_name, file_name, read_file(file_name))
    end
    container_name
  end
  
end
