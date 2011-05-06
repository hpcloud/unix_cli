module HP
  module Scalene
    class CLI < Thor
    
      map %w(buckets:rm buckets:delete buckets:del) => 'buckets:remove'
    
      desc "buckets:remove <name>", "remove a bucket"
      long_desc <<-DESC
  Remove a bucket. By default this command will only remove a bucket if it 
  empty. The --force flag will allow you to delete non-empty buckets. 
  Be careful with this flag or you could have a really bad day.

Examples:
  scalene bucket:remove :my_bucket          # delete 'my_bucket' if empty
  scalene bucket:remove :my_bucket --force  # delete regardless of contents

Aliases: buckets:rm, buckets:delete, buckets:del
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f', :desc => 'Force removal of non-empty bucket'
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