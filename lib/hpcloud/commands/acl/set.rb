module HP
  module Cloud
    class CLI < Thor
    
      desc 'acl:set <resource> <acl>', "set a given resource to a canned ACL"
      long_desc <<-DESC
  Set the Access Control List (ACL) for the specified resource, either a 
  container or object.
                 
  The supported ACL options include: private, public-read, public-read-write, 
  authenticated-read, authenticated-read-write, container-owner-read,
  container-owner-full-control, log-delivery-write.

Examples:
  hpcloud acl:set :my_container/file public-read  # Set 'file' ACL to public-read
  hpcloud acl:set :my_container private           # Set 'my_container' ACL private

Aliases: none

Note: Custom ACLs will be supported in a future release.
      DESC
      define_method 'acl:set' do |resource, acl|
        acl = acl.downcase
        unless CANNED_ACLS.include?(acl)
          error "Your ACL '#{acl}' is invalid.\nValid options are: #{CANNED_ACLS.join(', ')}."
        end
        type = Resource.detect_type(resource)
        container, path = Container.parse_resource(resource)
        begin
          if type == :object
            connection.put_object_acl(container, path, acl)
            display "ACL for #{resource} updated to #{acl}."
          elsif type == :container
            connection.put_container_acl(container, acl)
            display "ACL for #{resource} updated to #{acl}."
          else
            error 'Setting ACLs is only supported for containers and objects.', :not_supported
          end
        rescue Excon::Errors::NotFound, Excon::Errors::Forbidden => e
          display_error_message(e)
        end

      end
    
    end
  end
end