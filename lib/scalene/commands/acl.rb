require 'scalene/commands/acl/set'

module HP
  module Scalene
    class CLI < Thor
    
      CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write container-owner-read container-owner-full-control log-delivery-write)
    
      desc 'acl <object/container>', "view the ACL for an object or container"
      long_desc <<-DESC 
  View the Access Control List (ACL) for a container or object.

Examples:
  scalene acl :my_container/my_file.txt  # Get ACL for object 'my_file.txt'
  scalene acl :my_container'             # Get ACL for container 'my_container'

Aliases: none
      DESC
      def acl(resource)
        type = Resource.detect_type(resource)
        container, key = Container.parse_resource(resource)
        begin
          if type == :object
            acls = connection.get_object_acl(container, key).body["AccessControlList"]
            # TODO: print_table should be silenceable?
            print_table acls_for_table(acls)
          elsif type == :container
            acls = connection.get_container_acl(container).body["AccessControlList"]
            # TODO: print_table should be silenceable?
            print_table acls_for_table(acls)
          else
            error 'ACL viewing is only supported for containers and objects', :not_supported
          end
        rescue Excon::Errors::NotFound, Excon::Errors::Forbidden => e
          display_error_message(e)
        end
      end
    
      private
    
      # [{"Grantee"=>{"ID"=>"d1fac2d218a6de21ee37b7fc83783360c399f448"}, "Permission"=>"FULL_CONTROL"}]
      def acls_for_table(acls)
        table = []
        acls.each do |permission_set|
          permission_set["Grantee"].each do |key, grantee|
            table << [grantee, permission_set["Permission"]]
          end
        end
        table
      end
    
    end
  end
end