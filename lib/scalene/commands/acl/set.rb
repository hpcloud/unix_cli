module HP
  module Scalene
    class CLI < Thor
    
      desc 'acl:set <resource> <canned-acl>', "set a given resource to a canned ACL"
      long_desc "Set the Access Control List (ACL) for the specified resource, either a bucket or object.
                 The supported ACL options include: private, public-read, public-read-write, authenticated-read,
                 authenticated-read-write, bucket-owner-read, bucket-owner-full-control, log-delivery-write.
                \n\nExamples:
                \n\nscalene acl:set :my_bucket/my_file.txt public-read ==> Set the ACL for the file 'my_file.txt' to 'public-read'
                \n\nscalene acl:set :my_bucket private ==> Set the ACL for the bucket ':my_bucket' to 'private'

                \n\nAliases: none
                \n\nNote: For an explanation of the canned ACLs, visit http://..."

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