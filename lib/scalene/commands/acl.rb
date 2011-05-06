require 'scalene/commands/acl/set'

module HP
  module Scalene
    class CLI < Thor
    
      CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write bucket-owner-read bucket-owner-full-control log-delivery-write)
    
      desc 'acl <object/bucket>', "view the ACL for an object or bucket"
      long_desc <<-DESC 
  View the Access Control List (ACL) for a bucket or object.

Examples:
  scalene acl :my_bucket/my_file.txt  # Get ACL for object 'my_file.txt'
  scalene acl :my_bucket'             # Get ACL for bucket 'my_bucket'

Aliases: none
      DESC
      def acl(resource)
        type = Resource.detect_type(resource)
        bucket, key = Bucket.parse_resource(resource)
        begin
          if type == :object
            acls = connection.get_object_acl(bucket, key).body["AccessControlList"]
            # TODO: print_table should be silenceable?
            print_table acls_for_table(acls)
          elsif type == :bucket
            acls = connection.get_bucket_acl(bucket).body["AccessControlList"]
            # TODO: print_table should be silenceable?
            print_table acls_for_table(acls)
          else
            error 'ACL viewing is only supported for buckets and objects', :not_supported
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