
RSpec.configure do |config|
  
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
        tainer = connection.directories.get(container_name)
        unless tainer.nil?
          tainer.files.each do |file|
            begin
              puts "  - removing file '#{file.key}'" if verbose
              file.destroy
            end
          end
          connection.delete_container(container_name)
        end
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
