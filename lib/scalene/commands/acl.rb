require 'scalene/commands/acl/set'

module HP
  module Scalene
    class CLI < Thor
    
      CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write bucket-owner-read bucket-owner-full-control log-delivery-write)
    
      desc 'acl <resource>', "view the ACL for a given resource"
      long_desc "View the Access Control List (ACL) for the specified resource, either a bucket or object.
                 The supported ACL options include: private, public-read, public-read-write, authenticated-read, authenticated-read-write, bucket-owner-read, bucket-owner-full-control, log-delivery-write.
                \n\nExamples:
                \n\n'scalene acl :my_bucket/my_file.txt' ==> Get the ACL for the file 'my_file.txt'
                \n\n'scalene acl :my_bucket' ==> Get the ACL for the bucket ':my_bucket'

                \n\nAliases: none
                \n\nNote: The syntax convention we use for specifying a bucket is :my_bucket (the bucket name preceded by a colon)."
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