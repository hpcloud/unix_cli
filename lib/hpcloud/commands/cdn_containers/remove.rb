module HP
  module Cloud
    class CLI < Thor

      map %w(cdn:containers:rm cdn:containers:delete cdn:containers:del) => 'cdn:containers:remove'

      desc "cdn:containers:remove name [name ...]", "Remove containers from the CDN."
      long_desc <<-DESC
  Remove containers from the CDN. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:remove :tainer1 :tainer2                    # deletes :tainer1 and :tainer2 from the CDN
  hpcloud cdn:containers:remove :my_cdn_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: cdn:containers:rm, cdn:containers:delete, cdn:containers:del
      DESC
      CLI.add_common_options
      define_method "cdn:containers:remove" do |name, *names|
        cli_command(options) {
          names = [name] + names
          names.each { |name|
            begin
              Connection.instance.cdn.delete_container(name)
              display "Removed container '#{name}' from the CDN."
            rescue Excon::Errors::NotFound, Fog::CDN::HP::NotFound
              error_message "You don't have a container named '#{name}' on the CDN.", :not_found
            end
          }
        }
      end
    end
  end
end
