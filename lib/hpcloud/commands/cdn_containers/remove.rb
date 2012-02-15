module HP
  module Cloud
    class CLI < Thor

      map %w(cdn:containers:rm cdn:containers:delete cdn:containers:del) => 'cdn:containers:remove'

      desc "cdn:containers:remove <name>", "remove a container from the CDN"
      long_desc <<-DESC
  Remove a container from the CDN.

Examples:
  hpcloud cdn:containers:remove :my_cdn_container          # deletes 'my_cdn_container' from the CDN

Aliases: cdn:containers:rm, cdn:containers:delete, cdn:containers:del
      DESC
      define_method "cdn:containers:remove" do |name|
        begin
          connection(:cdn).delete_container(name)
          display "Removed container '#{name}' from the CDN."
        rescue Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        rescue Excon::Errors::NotFound, Fog::Storage::HP::NotFound
          error "You don't have a container named '#{name}' on the CDN.", :not_found
        end
      end

    end
  end
end