module HP
  module Scalene
    class CLI < Thor
    
      desc 'acl:set <resource> <acl>', "set a given resource to a canned ACL"
      long_desc <<-DESC
  Set the Access Control List (ACL) for the specified resource, either a 
  bucket or object.
                 
  The supported ACL options include: private, public-read, public-read-write, 
  authenticated-read, authenticated-read-write, bucket-owner-read, 
  bucket-owner-full-control, log-delivery-write.

Examples:
  scalene acl:set :my_bucket/file public-read  # Set 'file' ACL to public-read
  scalene acl:set :my_bucket private           # Set 'my_bucket' ACL private

Aliases: none

Note: Custom ACLs will be supported in a future release.
      DESC
      define_method 'acl:set' do |resource, acl|
        acl = acl.downcase
        unless CANNED_ACLS.include?(acl)
          error "Your ACL '#{acl}' is invalid.\nValid options are: #{CANNED_ACLS.join(', ')}."
        end
        type = Resource.detect_type(resource)
        bucket, path = Bucket.parse_resource(resource)
        begin
          if type == :object
            connection.put_object_acl(bucket, path, acl)
            display "ACL for #{resource} updated to #{acl}"
          elsif type == :bucket
            connection.put_bucket_acl(bucket, acl)
            display "ACL for #{resource} updated to #{acl}"
          else
            error 'Setting ACLs is only supported for buckets and objects', :not_supported
          end
        rescue Excon::Errors::NotFound, Excon::Errors::Forbidden => e
          display_error_message(e)
        end

      end
    
    end
  end
end