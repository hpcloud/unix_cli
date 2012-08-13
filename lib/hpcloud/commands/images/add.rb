module HP
  module Cloud
    class CLI < Thor

      desc "images:add <name> <server_name>", "add an image from an existing server"
      long_desc <<-DESC
  Add a new image from an existing server to your compute account. Optionally, you may pass in metadata or an availability zone.

Examples:
  hpcloud images:add my_image my_server                           # Creates a new image named 'my_image' from an existing server named 'my_server'
  hpcloud images:add my_image my_server -m this=that              # Creates a new image named 'my_image' from an existing server named 'my_server' with metadata
  hpcloud images:add my_image my_server -z az-2.region-a.geo-1    # Optionally specify an availability zone

Aliases: none
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      define_method "images:add" do |name, server_name|
        # setup connection for compute service
        begin
          Connection.instance.set_options(options)
          img = HP::Cloud::ImageHelper.new()
          img.name = name
          img.set_server(server_name)
          img.meta.set_metadata(options[:metadata])
          if img.save == true
            display "Created image '#{name}' with id '#{img.id}'."
          else
            display_error_message(img.error_string, img.error_code)
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden, Excon::Errors::Conflict => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
