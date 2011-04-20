module HP
  module Scalene
    class CLI < Thor
    
      map %w(buckets:rm buckets:delete buckets:del) => 'buckets:remove'
    
      desc "buckets:remove <name>", "remove a bucket"
      long_desc "Remove a bucket.  By default this command only deletes an empty bucket.
                  Use the -f force flag to also delete the files the bucket contains.
                  Be careful with this flag or you could have a really bad day.
                  You can specify the bucket name with or without the preceding colon, i.e. 'my_bucket' or ':my_bucket'.
                \n\nExamples:
                \n\nscalene bucket:remove my_bucket ==> Deletes an empty bucket called 'my_bucket'
                \n\nscalene bucket:rm :my_bucket -f ==> Deletes a bucket called 'my_bucket'and all the files in it

                \n\nAliases: 'buckets:rm', 'buckets:delete', 'buckets:del'
                \n\nNote: "
      method_option :force, :default => false, :type => :boolean, :aliases => '-f'
      define_method "buckets:remove" do |name|
        name = Bucket.bucket_name_for_service(name)
        bucket = connection.directories.get(name)
        if bucket
          if options.force?
            bucket.files.each { |file| file.destroy }
          end
          begin
            bucket.destroy
            display "Removed bucket '#{name}'."
          rescue Excon::Errors::Conflict => error
            display_error_message(error)
          end
        else
          error "You don't have a bucket named '#{name}'."
        end
      end
    
    end
  end
end