module HPCloud
  class CLI < Thor
    
    desc "buckets:add <name>", "add a bucket"
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