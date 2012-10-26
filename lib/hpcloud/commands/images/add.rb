module HP
  module Cloud
    class CLI < Thor

      desc "images:add <name> <server_name>", "Add an image from an existing server."
      long_desc <<-DESC
  Add a new image from an existing server to your compute account. Optionally, you may pass in metadata or an availability zone.

Examples:
  hpcloud images:add my_image my_server                           # Creates a new image named 'my_image' from an existing server named 'my_server'
  hpcloud images:add my_image my_server -m this=that              # Creates a new image named 'my_image' from an existing server named 'my_server' with metadata
  hpcloud images:add my_image my_server -z az-2.region-a.geo-1    # Optionally specify an availability zone
      DESC
      CLI.add_common_options
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      define_method "images:add" do |name, server_name|
        cli_command(options) {
          img = HP::Cloud::ImageHelper.new()
          img.name = name
          img.set_server(server_name)
          img.meta.set_metadata(options[:metadata])
          if img.save == true
            display "Created image '#{name}' with id '#{img.id}'."
          else
            display_error_message(img.error_string, img.error_code)
          end
        }
      end

    end
  end
end
