module HP
  module Cloud
    class CLI < Thor

      map %w(cdn:containers:rm cdn:containers:delete cdn:containers:del) => 'cdn:containers:remove'

      desc "cdn:containers:remove <name>", "Remove a container from the CDN."
      long_desc <<-DESC
  Remove a container from the CDN. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:remove :my_cdn_container                    # deletes 'my_cdn_container' from the CDN
  hpcloud cdn:containers:remove :my_cdn_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: cdn:containers:rm, cdn:containers:delete, cdn:containers:del
      DESC
      CLI.add_common_options
      define_method "cdn:containers:remove" do |name|
        cli_command(options) {
          begin
            connection(:cdn, options).delete_container(name)
            display "Removed container '#{name}' from the CDN."
          rescue Excon::Errors::NotFound, Fog::CDN::HP::NotFound
            error "You don't have a container named '#{name}' on the CDN.", :not_found
          end
        }
      end
    end
  end
end
