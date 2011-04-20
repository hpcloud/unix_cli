module HP
  module Scalene
    class CLI < Thor
    
      desc "buckets:add <name>", "add a bucket"
      long_desc "Add a new bucket to your storage account, with the specified name.
                  You can specify the bucket name with or without the preceding colon, i.e. 'my_bucket' or ':my_bucket'.
                \n\nExamples:
                \n\nscalene bucket:add my_bucket ==> Creates a new bucket called 'my_bucket'

                \n\nAliases: none
                \n\nNote: "
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