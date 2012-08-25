module HP
  module Cloud
    class CLI < Thor

      desc "cdn:containers:add <name>", "add a container to the CDN"
      long_desc <<-DESC
  Add an existing container from your storage account to the CDN. Container name can be specified with
  or without the preceding colon: 'my_container' or ':my_container'. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:add :my_cdn_container                    # Creates a new container called 'my_cdn_container'
  hpcloud cdn:containers:add :my_cdn_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: none
      DESC
      CLI.add_common_options()
      define_method "cdn:containers:add" do |name|
        name = Container.container_name_for_service(name)
        # check if the container exists on the storage account
        begin
          ### TODO: At some point in time, need an option to pass in Storage avl zone as well. Currently picking up from config.
          ### Another option is to pass the same avl zone in to storage assuming Storage and CDN services will be one to one
          if connection(:storage).directories.get(name)
            response = connection(:cdn, options).put_container(name)
            display "Added container '#{name}' to the CDN."
          else
            error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
          end
        rescue Fog::Storage::HP::NotFound
          error "The container '#{name}' does not exist in your storage account. Please create the storage container first and then add it to the CDN.", :incorrect_usage
        rescue Fog::HP::Errors::ServiceError, Fog::CDN::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::Conflict, Excon::Errors::NotFound => error
          display_error_message(error, :not_found)
        end
      end

    end
  end
end
