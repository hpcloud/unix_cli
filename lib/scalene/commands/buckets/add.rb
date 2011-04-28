module HP
  module Scalene
    class CLI < Thor
    
      desc "buckets:add <name>", "add a bucket"
      long_desc <<-DESC
  Add a new bucket to your storage account. Bucket name can be specified with 
  or without the preceding colon: 'my_bucket' or ':my_bucket'.

Examples:
  scalene bucket:add :my_bucket  # Creates a new bucket called 'my_bucket'

Aliases: none
      DESC
      define_method "buckets:add" do |name|
        begin
          name = Bucket.bucket_name_for_service(name)
          connection.directories.create(:key => name)
          display "Created bucket '#{name}'."
        rescue Excon::Errors::Conflict => error
          display_error_message(error)
        end
      end
    
    end
  end
end