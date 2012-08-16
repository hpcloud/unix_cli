module HP
  module Cloud
    class CLI < Thor

      map %w(cdn:containers:rm cdn:containers:delete cdn:containers:del) => 'cdn:containers:remove'

      desc "cdn:containers:remove <name>", "remove a container from the CDN"
      long_desc <<-DESC
  Remove a container from the CDN. Optionally, an availability zone can be passed.

Examples:
  hpcloud cdn:containers:remove :my_cdn_container                    # deletes 'my_cdn_container' from the CDN
  hpcloud cdn:containers:remove :my_cdn_container -z region-a.geo-1  # Optionally specify an availability zone

Aliases: cdn:containers:rm, cdn:containers:delete, cdn:containers:del
      DESC
      GOPTS.each { |k,v| method_option(k, v) }
      define_method "cdn:containers:remove" do |name|
        begin
          connection(:cdn, options).delete_container(name)
          display "Removed container '#{name}' from the CDN."
        rescue Excon::Errors::NotFound, Fog::CDN::HP::NotFound
          error "You don't have a container named '#{name}' on the CDN.", :not_found
        rescue Fog::HP::Errors::ServiceError, Fog::CDN::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end
