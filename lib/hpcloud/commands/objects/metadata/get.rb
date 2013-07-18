module HP
  module Cloud
    class CLI < Thor

      desc "objects:metadata:get <name> [attribute...]", "Get the value of an attribute of a container."
      long_desc <<-DESC
  Get the value of an attribute for an existing container. The allowed attributes whose value can be retrieved are:
  * 'X-Ttl'
  * 'X-Cdn-Uri'
  * 'X-Cdn-Enabled'
  * 'X-Log-Retention'. 
  
  Optionally, you can specify an availability zone.

Examples:
  hpcloud objects:metadata:get :my_container                            # List all the attributes
  hpcloud objects:metadata:get :my_container "X-Cdn-Uri"                # Get the value of the attribute 'X-Cdn-Uri'
  hpcloud objects:metadata:get :my_container "X-Ttl" -z region-a.geo-1  # Get the value of the attribute `X-Ttl` for availability zone `regioni-a.geo`
      DESC
      CLI.add_common_options
      define_method "objects:metadata:get" do |name, *attributes|
        cli_command(options) {
          resource = ResourceFactory.create(Connection.instance.storage, name)
          if resource.head
            hsh = resource.headers.dup
            hsh.delete('Accept-Ranges')
            hsh.delete('Content-Length')
            hsh.delete('Date')
            hsh.delete('Etag')
            hsh.delete('Last-Modified')
            hsh.delete('X-Timestamp')
            hsh.delete('X-Trans-Id')
            keyo = hsh.keys.sort
            keyo.each{ |k|
              v = hsh[k]
              v = "\n" if v.nil?
              @log.display "#{k} #{v}"
            }
          else
            @log.error resource.cstatus
          end
        }
      end
    end
  end
end
