module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:add <name>", "add a container to the CDN"
      long_desc <<-DESC
  Add an existing container from your storage account to the CDN. Container name can be specified with
  or without the preceding colon: 'my_container' or ':my_container'.

Examples:
  hpcloud cdn:containers:add :my_cdn_container  # Creates a new container called 'my_cdn_container'

Aliases: none
      DESC
      define_method "cdn:containers:add" do |name|
        name = Container.container_name_for_service(name)
        # check if the container exists on the storage account
        begin
          if connection.directories.get(name)
            begin
              response = connection(:cdn).put_container(name)
              display "Added container '#{name}' to the CDN."
            rescue Fog::CDN::HP::Error => error
              display_error_message(error, :permission_denied)
            rescue Excon::Errors::Conflict, Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
              display_error_message(error, :permission_denied)
            end
          else
            error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
          end
        rescue Fog::Storage::HP::NotFound
          error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
        rescue Excon::Errors::Conflict, Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end