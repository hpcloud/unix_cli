module HP
  module Scalene
    class CLI < Thor
    
      desc 'acl:set <resource> <canned-acl>', "set a given resource to a canned ACL"
      define_method 'acl:set' do |resource, acl|
        acl = acl.downcase
        unless CANNED_ACLS.include?(acl)
          error "Your ACL '#{acl}' is invalid.\nValid options are: #{CANNED_ACLS.join(', ')}."
        end
        bucket, path = Bucket.parse_resource(resource)
        directory = connection.directories.get(bucket)
        if directory
          file = directory.files.get(path)
          if file
            begin
              connection.put_object_acl(bucket, path, acl)
              # can't use model for now as doesn't preserve content-type
              # file.acl = acl
              # file.save
              display "ACL for #{resource} updated to #{acl}"
            end
          else
            error "You don't have a file '#{path}'.", :not_found
          end
        else
          error "You don't have a bucket '#{bucket}'.", :not_found
        end
      end
    
    end
  end
end