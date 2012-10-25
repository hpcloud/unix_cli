module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:add name [name ...]", "Add containers to the CDN."
      long_desc <<-DESC
  Add existing containers from your storage account to the CDN. Container names can be specified with or without the preceding colon: 'my_container' or ':my_container'. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:add :tainer1 :tainer2                    # Adds the containers to the CDN
  hpcloud cdn:containers:add :my_cdn_container -z region-a.geo-1  # Add the container to the CDN in the specified availability zone
      DESC
      CLI.add_common_options
      define_method "cdn:containers:add" do |name|
        cli_command(options) {
          name = Container.container_name_for_service(name)
          begin
            if Connection.instance.storage.directories.get(name)
              response = Connection.instance.cdn.put_container(name)
              display "Added container '#{name}' to the CDN."
            else
              error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
            end
          rescue Fog::Storage::HP::NotFound
            error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
          end
        }
      end
    end
  end
end
