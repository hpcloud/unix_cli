module HPCloud
  class CLI < Thor
    
    CANNED_ACLS = %w(private public-read public-read-write authenticated-read authenticated-read-write bucket-owner-read bucket-owner-full-control log-delivery-write)
    
    desc 'acl <resource> <canned-acl>', "set a given resource to a canned ACL"
    def acl(resource, acl)
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
            puts "ACL for #{resource} updated to #{acl}"
          end
        else
          error "You don't have a file '#{path}'."
        end
      else
        error "You don't have a bucket '#{bucket}'."
      end
    end
    
  end
end